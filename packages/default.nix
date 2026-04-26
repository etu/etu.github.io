{ pkgs, ... }:
let
  domain = "elis.nu";
  computeColors = pkgs.callPackage ./compute-colors.nix { };
in
pkgs.stdenv.mkDerivation {
  name = domain;

  src = ../.;

  nativeBuildInputs = [ pkgs.hugo computeColors ];

  buildPhase = ''
    compute-colors --validate config.yaml
    hugo --logLevel debug --minify
  '';

  installPhase = ''
    cp -vr public/ $out

    # Set domain for github pages
    echo ${domain} > $out/CNAME
  '';
}
