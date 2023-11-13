{
  description = "etu/etu.github.io";

  inputs.flake-utils.url = "flake-utils";

  outputs = {
    flake-utils,
    nixpkgs,
    ...
  }:
    flake-utils.lib.eachSystem ["x86_64-linux"] (system: let
      pkgs = import nixpkgs {inherit system;};
    in {
      formatter = pkgs.alejandra;

      packages.default = pkgs.stdenv.mkDerivation {
        name = "site";
        src = ./.;

        buildInputs = with pkgs; [
          ((emacsPackagesFor emacs-nox).emacsWithPackages (epkgs:
            with epkgs; [
              # Newer org-mode than built-in
              org

              # Generate RSS feeds
              webfeeder

              # Deps for syntax highlighting for some languages
              go-mode
              htmlize
              nix-mode
              php-mode
              yaml-mode
            ]))

          sassc
        ];

        buildPhase = ''
          mkdir -p output/html/

          emacs --batch --load=publish.el
          cp src/CNAME output/html/
          sassc --style=compressed src/style.scss output/html/style.css

          cp output/html/imgs/elis.jpg output/html/imgs/favicon.jpg
        '';

        installPhase = ''
          cp -vr output/html/ $out
        '';
      };
    });
}