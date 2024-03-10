{
  description = "etu/etu.github.io";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    flake-utils.url = "flake-utils";
    taserud-theme-albatross.url = "github:TaserudConsulting/theme-albatross";
    taserud-theme-albatross.inputs.flake-utils.follows = "flake-utils";
  };

  outputs = {
    self,
    flake-utils,
    nixpkgs,
    ...
  } @ inputs:
    flake-utils.lib.eachSystem ["x86_64-linux"] (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      tpkgs = inputs.taserud-theme-albatross.packages.${system};
      domain = "elis.nu";
    in {
      formatter = pkgs.alejandra;

      packages.hugo = tpkgs.hugo;
      packages.theme = tpkgs.theme;

      packages.website = pkgs.stdenv.mkDerivation {
        name = domain;

        src = ./src;

        nativeBuildInputs = [
          tpkgs.hugo
        ];

        buildPhase = ''
          # Install theme
          mkdir -p themes
          ln -s ${tpkgs.theme} themes/${tpkgs.theme.theme-name}

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
