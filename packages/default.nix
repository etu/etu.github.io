{ pkgs, ... }:
let
  domain = "elis.nu";
  hugo = pkgs.symlinkJoin {
    name = "hugo-${pkgs.hugo.version}-dart-sass-${pkgs.dart-sass.version}-bundle";
    buildInputs = [ pkgs.makeWrapper ];
    paths = [
      pkgs.hugo
      pkgs.dart-sass
    ];
    postBuild = "wrapProgram $out/bin/hugo --prefix PATH : ${pkgs.dart-sass}/bin";
    meta.mainProgram = "hugo";
  };
in
pkgs.stdenv.mkDerivation {
  name = domain;

  src = ../.;

  nativeBuildInputs = [ hugo ];

  buildPhase = ''
    hugo --logLevel debug --minify
  '';

  installPhase = ''
    cp -vr public/ $out

    # Set domain for github pages
    echo ${domain} > $out/CNAME
  '';
}
