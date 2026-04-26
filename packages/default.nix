{ pkgs, ... }:
let
  domain = "elis.nu";
in
pkgs.stdenv.mkDerivation {
  name = domain;

  src = ../.;

  nativeBuildInputs = [ pkgs.hugo ];

  buildPhase = ''
    hugo --logLevel debug --minify
  '';

  installPhase = ''
    cp -vr public/ $out

    # Set domain for github pages
    echo ${domain} > $out/CNAME
  '';
}
