{
  description = "etu/etu.github.io";

  inputs.flake-utils.url = "flake-utils";

  outputs = {
    self,
    flake-utils,
    nixpkgs,
    ...
  }:
    flake-utils.lib.eachSystem ["x86_64-linux"] (system: let
      pkgs = import nixpkgs {inherit system;};
      domain = "elis.nu";
    in {
      formatter = pkgs.alejandra;

      packages.hugo = pkgs.symlinkJoin {
        name = "hugo-${pkgs.hugo.version}-dart-sass-embedded-${pkgs.dart-sass.version}-bundle";

        buildInputs = [pkgs.makeWrapper];
        paths = [pkgs.hugo pkgs.dart-sass];

        postBuild = "wrapProgram $out/bin/hugo --prefix PATH : ${pkgs.dart-sass}/bin";

        meta.mainProgram = "hugo";
      };

      packages.fontawesome = let
        version = "6.5.1";
      in
        pkgs.stdenv.mkDerivation {
          pname = "fontawesome-free";
          inherit version;

          src = pkgs.fetchzip {
            url = "https://use.fontawesome.com/releases/v${version}/fontawesome-free-${version}-web.zip";
            hash = "sha256-gXXhKyTDC/Q6PBzpWRFvx/TxcUd3msaRSdC3ZHFzCoc=";
          };

          buildPhase = ":";

          installPhase = ''
            mkdir -p $out

            cp -vr scss webfonts $out
          '';
        };

      packages.default = pkgs.stdenv.mkDerivation {
        name = domain;

        src = ./src;

        nativeBuildInputs = [
          self.packages.${system}.hugo
        ];

        buildPhase = ''
          # Install fontawesome resources
          install -m 644 -D ${self.packages.${system}.fontawesome}/scss/* -t themes/elisnu/assets/scss/fontawesome
          install -m 644 -D ${self.packages.${system}.fontawesome}/webfonts/* -t themes/elisnu/static/fonts/fontawesome

          # Build page
          hugo --logLevel debug
        '';

        installPhase = ''
          cp -vr public/ $out

          # Set domain for github pages
          echo ${domain} > $out/CNAME
        '';
      };
    });
}
