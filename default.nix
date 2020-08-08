{ pkgs ? (import <nixpkgs> {}) }:

pkgs.stdenv.mkDerivation {
  name = "site";
  src = ./.;

  buildInputs = with pkgs; [
    (emacsWithPackages (epkgs: with epkgs; [
      # Newer org-mode than built-in
      org

      # Generate RSS feeds
      webfeeder

      # Deps for syntax highlighting for some languages
      htmlize
      php-mode
      nix-mode
    ]))

    sassc
  ];

  buildPhase = ''
    emacs --batch --load=publish.el
    cp src/CNAME public/
    sassc --style=compressed src/style.scss public/style.css

    cp public/imgs/etu.jpg public/imgs/favicon.jpg
  '';

  installPhase = ''
    cp -vr public/ $out
  '';
}
