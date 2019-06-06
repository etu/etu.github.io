with import <nixpkgs> {};

stdenv.mkDerivation rec {
  name = "site";
  src = ./.;

  buildInputs = with pkgs; [ ];

  buildPhase = ''
    cp -vr src/ public/
  '';

  installPhase = ''
    cp -vr public/ $out
  '';
}
