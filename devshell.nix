{ pkgs, ... }:
let
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
pkgs.mkShell {
  packages = [
    hugo
    pkgs.just
  ];
}
