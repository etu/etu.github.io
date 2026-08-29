{ pkgs, ... }:
pkgs.mkShell {
  packages = [
    pkgs.hugo
    pkgs.just
    pkgs.pagefind
  ];
}
