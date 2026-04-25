{ pkgs, ... }:
pkgs.writeShellApplication {
  name = "update-model-viewer";
  runtimeInputs = [pkgs.curl pkgs.gnused];
  text = ''
    if [ $# -ne 1 ]; then
      echo "Usage: update-model-viewer VERSION"
      echo "Example: update-model-viewer 3.5.0"
      exit 1
    fi

    version="$1"
    root="$(git rev-parse --show-toplevel)"
    url="https://ajax.googleapis.com/ajax/libs/model-viewer/''${version}/model-viewer.min.js"
    license="''${root}/themes/albatross/static/js/model-viewer.LICENSE"

    echo "Downloading model-viewer ''${version}..."
    curl -sL "''${url}" -o "''${root}/themes/albatross/static/js/model-viewer.min.js"

    echo "Updating LICENSE..."
    sed -i "s|^Version: .*|Version: ''${version}|" "''${license}"
    sed -i "s|/model-viewer/[^/]*/model-viewer|/model-viewer/''${version}/model-viewer|g" "''${license}"
    sed -i "s|^Downloaded: .*|Downloaded: $(date +%Y-%m-%d)|" "''${license}"

    echo "Done! model-viewer ''${version} updated."
  '';
}
