{
  description = "etu/etu.github.io";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    flake-utils.url = "flake-utils";
    theme-albatross.url = "github:etu/hugo-theme-albatross";
    theme-albatross.inputs.flake-utils.follows = "flake-utils";
    _3dmodels.url = "github:etu/3d-models";
    _3dmodels.inputs.flake-utils.follows = "flake-utils";
  };

  outputs = {
    flake-utils,
    nixpkgs,
    ...
  } @ inputs:
    flake-utils.lib.eachSystem ["x86_64-linux"] (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      tpkgs = inputs.theme-albatross.packages.${system};
      domain = "elis.nu";

      # Helper function to render all the assets for the 3d model page
      _3dmodelsPage = let
        jsonData = builtins.toJSON (map (pkg: {
          title = pkg.meta.description or pkg.name;
          description = pkg.meta.longDescription or "";
          license.name = pkg.meta.license.spdxId;
          license.url = pkg.meta.license.url;
          homepage = pkg.meta.homepage or "";
          files = [
            {
              name = "${pkg.name}.3mf";
              modelFile = "/3d-models/${pkg.name}.3mf";
              modelViewer = "/3d-models/${pkg.name}.glb";
            }
          ];
        }) (builtins.attrValues inputs._3dmodels.packages.${system}));

        copyCommands = builtins.concatStringsSep "\n" (map (pkg: ''
          echo ${pkg.name}
          cp -v ${pkg}/model.3mf $out/static/${pkg.name}.3mf
          cp -v ${pkg}/model.glb $out/static/${pkg.name}.glb
        '') (builtins.attrValues inputs._3dmodels.packages.${system}));

        mkPageMarkdown = pkgs.writeText "3dmodels.md" ''
          ---
          title: ~elis/3d-models/
          type: 3d-models
          model3d: ${jsonData}
          ---
          This is an overview of different 3D models that I have created.
        '';
      in
        pkgs.runCommand "3dmodels" {} ''
          mkdir -p $out/static
          cp -v ${mkPageMarkdown} $out/index.md

          ${copyCommands}
        '';
    in {
      formatter = pkgs.alejandra;

      packages.theme = tpkgs.theme;

      packages._3dmodelsPage = _3dmodelsPage;
      packages.default = pkgs.stdenv.mkDerivation {
        name = domain;

        src = ./src;

        nativeBuildInputs = [
          tpkgs.hugo
        ];

        buildPhase = ''
          # Install theme
          mkdir -p themes
          ln -s ${tpkgs.theme} themes/${tpkgs.theme.theme-name}

          # Install 3d models
          mkdir -p static/3d-models
          install -m 644 -v ${_3dmodelsPage}/index.md content/3d-models.md
          install -m 644 -v -D ${_3dmodelsPage}/static/* -t static/3d-models

          # Build page
          hugo --logLevel debug
        '';

        installPhase = ''
          cp -vr public/ $out

          # Set domain for github pages
          echo ${domain} > $out/CNAME
        '';
      };

      apps = {
        default = {
          type = "app";
          program = let
            scriptDrv = pkgs.writeShellScriptBin "local.sh" ''
              set -euo pipefail

              nix build .#theme --out-link src/themes/${tpkgs.theme.theme-name}

              rm -rf src/static/3d-models src/content/3d-models.md
              mkdir -p src/static/3d-models
              install -m 644 -v $(nix build .#_3dmodelsPage --print-out-paths --no-link)/index.md src/content/3d-models.md
              install -m 644 -v -D $(nix build .#_3dmodelsPage --print-out-paths --no-link)/static/* -t src/static/3d-models

              cd src/
              sleep 1 && ${pkgs.xdg-utils}/bin/xdg-open "http://localhost:1313/" &

              ${tpkgs.hugo}/bin/hugo server --logLevel debug --disableFastRender --gc
            '';
          in "${scriptDrv}/bin/local.sh";
        };
      };
    });
}
