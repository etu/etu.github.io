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

      # Theme for code highlight
      dracula-theme

      # Deps for syntax highlighting for some languages
      htmlize
      php-mode
      nix-mode
    ]))
  ];

  buildPhase = ''
    emacs --batch --load=publish.el
    cp src/CNAME public/
  '';

  installPhase = ''
    cp -vr public/ $out
  '';
}
