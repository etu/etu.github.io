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

      update-3d-models = pkgs.writeShellApplication {
        name = "update-3d-models";
        runtimeInputs = [pkgs.curl pkgs.jq pkgs.gnutar];
        text = ''
          root="$(git rev-parse --show-toplevel)"

          echo "Fetching latest 3d-models release..."
          tag=$(curl -sf "https://api.github.com/repos/etu/3d-models/releases/latest" | jq -r '.tag_name')
          url="https://github.com/etu/3d-models/releases/download/''${tag}/3d-models.tar.gz"
          echo "Latest release: ''${tag}"

          echo "Downloading release..."
          tmpdir=$(mktemp -d)
          trap 'chmod -R u+w "''${tmpdir}"; rm -rf "''${tmpdir}"' EXIT

          curl -sL "''${url}" | tar -xz -C "''${tmpdir}" --strip-components=1

          echo "Generating 3d-models page..."
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
          }]' "''${tmpdir}/metadata.json")

          cat > "''${root}/content/3d-models.md" <<EOF
          ---
          title: ~elis/3d-models/
          type: 3d-models
          model3d: ''${model3d}
          ---
          This is an overview of different 3D models that I have created.
          EOF

          echo "Copying model files..."
          rm -rf "''${root}/static/3d-models"
          mkdir -p "''${root}/static/3d-models"
          cp "''${tmpdir}"/models/*.3mf "''${tmpdir}"/models/*.glb "''${root}/static/3d-models/"
          chmod -R u+w "''${root}/static/3d-models/"

          echo "Done! Updated to release: ''${tag}"
        '';
      };
    in {
      formatter = pkgs.alejandra;

      packages.update-3d-models = update-3d-models;
      packages.default = pkgs.stdenv.mkDerivation {
        name = domain;

        src = ./.;

        nativeBuildInputs = [hugo];

        buildPhase = ''
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
