with import <nixpkgs> {};

stdenv.mkDerivation rec {
  name = "site";
  src = ./.;

  buildInputs = with pkgs; [ ];

  buildPhase = ''
    mkdir public/
    cp -r CNAME D57EFA625C9A925F.asc Elis_Hirwing_CV.pdf imgs index.html script.js style.css public/
  '';

  installPhase = ''
    cp -vr public/ $out
  '';
}
