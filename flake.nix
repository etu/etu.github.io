{
  description = "etu/etu.github.io";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    flake-utils.url = "flake-utils";
  };

  outputs = {
    flake-utils,
    nixpkgs,
    ...
  }:
    flake-utils.lib.eachSystem ["x86_64-linux"] (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      domain = "elis.nu";

      hugo = pkgs.symlinkJoin {
        name = "hugo-${pkgs.hugo.version}-dart-sass-embedded-${pkgs.dart-sass.version}-bundle";

        buildInputs = [pkgs.makeWrapper];
        paths = [pkgs.hugo pkgs.dart-sass];

        postBuild = "wrapProgram $out/bin/hugo --prefix PATH : ${pkgs.dart-sass}/bin";

        meta.mainProgram = "hugo";
      };

      # Pre-built release from github:etu/3d-models.
      # Run `nix run .#update-3d-models` to update the URL and hash.
      _3dmodelsRelease = pkgs.fetchzip {
        url = "https://github.com/etu/3d-models/releases/download/2026-04-25-764f1c4/3d-models.tar.gz"; # 3d-models-url
        hash = "sha256-8kUtfbwc1nqc7vGX72J6aYmMY68OvCD59LNPff6Tld8="; # 3d-models-hash
      };

      _3dmodelsPage =
        pkgs.runCommand "3dmodels" {
          buildInputs = [pkgs.jq];
        } ''
          mkdir -p $out/static

          model3d=$(jq -c '[.[] | {
            title: .title,
            description: .description,
            license: {name: .license.spdxId, url: .license.url},
            homepage: .homepage,
            files: [{
              name: (.name + ".3mf"),
              modelFile: ("/3d-models/" + .name + ".3mf"),
              modelViewer: ("/3d-models/" + .name + ".glb")
            }]
          }]' ${_3dmodelsRelease}/metadata.json)

          cat > $out/index.md << EOF
          ---
          title: ~elis/3d-models/
          type: 3d-models
          model3d: $model3d
          ---
          This is an overview of different 3D models that I have created.
          EOF

          cp ${_3dmodelsRelease}/models/*.3mf $out/static/
          cp ${_3dmodelsRelease}/models/*.glb $out/static/
        '';

      update-3d-models = pkgs.writeShellApplication {
        name = "update-3d-models";
        runtimeInputs = [pkgs.curl pkgs.jq];
        text = ''
          flake="$(git rev-parse --show-toplevel)/flake.nix"

          echo "Fetching latest 3d-models release..."
          tag=$(curl -sf "https://api.github.com/repos/etu/3d-models/releases/latest" | jq -r '.tag_name')
          url="https://github.com/etu/3d-models/releases/download/''${tag}/3d-models.tar.gz"
          echo "Latest release: ''${tag}"

          echo "Fetching hash..."
          hash=$(nix store prefetch-file --hash-type sha256 --unpack --json "$url" | jq -r '.hash')
          echo "Hash: ''${hash}"

          sed -i "s|url = \"[^\"]*\"; # 3d-models-url|url = \"''${url}\"; # 3d-models-url|" "$flake"
          sed -i "s|hash = \"[^\"]*\"; # 3d-models-hash|hash = \"''${hash}\"; # 3d-models-hash|" "$flake"

          echo "Updated flake.nix"
        '';
      };
    in {
      formatter = pkgs.alejandra;

      packages._3dmodelsPage = _3dmodelsPage;
      packages.update-3d-models = update-3d-models;
      packages.default = pkgs.stdenv.mkDerivation {
        name = domain;

        src = ./src;

        nativeBuildInputs = [hugo];

        buildPhase = ''
          # Install 3d models
          mkdir -p static/3d-models
          install -m 644 -v ${_3dmodelsPage}/index.md content/3d-models.md
          install -m 644 -v -D ${_3dmodelsPage}/static/* -t static/3d-models

          # Build page
          hugo --logLevel debug --minify
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

              rm -rf src/static/3d-models src/content/3d-models.md
              mkdir -p src/static/3d-models
              install -m 644 -v $(nix build .#_3dmodelsPage --print-out-paths --no-link)/index.md src/content/3d-models.md
              install -m 644 -v -D $(nix build .#_3dmodelsPage --print-out-paths --no-link)/static/* -t src/static/3d-models

              cd src/
              sleep 1 && ${pkgs.xdg-utils}/bin/xdg-open "http://localhost:1313/" &

              ${hugo}/bin/hugo server --logLevel debug --disableFastRender --gc
            '';
          in "${scriptDrv}/bin/local.sh";
        };

        update-3d-models = {
          type = "app";
          program = "${update-3d-models}/bin/update-3d-models";
        };
      };
    });
}
