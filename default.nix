with import <nixpkgs> {};

stdenv.mkDerivation rec {
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

    sass
  ];

  buildPhase = ''
    emacs --batch --load=publish.el
    cp src/CNAME public/
    scss --sourcemap=none --style=compressed src/style.scss public/style.css
  '';

  installPhase = ''
    cp -vr public/ $out
  '';
}
