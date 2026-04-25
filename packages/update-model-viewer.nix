{ pkgs, ... }:
pkgs.writeShellApplication {
  name = "update-model-viewer";
  runtimeInputs = [pkgs.curl pkgs.jq pkgs.gnused];
  text = ''
    root="$(git rev-parse --show-toplevel)"
    license="''${root}/themes/albatross/static/js/model-viewer.LICENSE"

    if [ $# -eq 1 ]; then
      version="$1"
    else
      echo "Fetching latest model-viewer release..."
      tag=$(curl -sf "https://api.github.com/repos/google/model-viewer/releases/latest" | jq -r '.tag_name')
      version="''${tag#v}"
    fi

    url="https://ajax.googleapis.com/ajax/libs/model-viewer/''${version}/model-viewer.min.js"
    echo "Downloading model-viewer ''${version}..."

    curl -sL "''${url}" -o "''${root}/themes/albatross/static/js/model-viewer.min.js"

    echo "Updating LICENSE..."
    sed -i "s|^Version: .*|Version: ''${version}|" "''${license}"
    sed -i "s|/model-viewer/[^/]*/model-viewer|/model-viewer/''${version}/model-viewer|g" "''${license}"
    sed -i "s|^Downloaded: .*|Downloaded: $(date +%Y-%m-%d)|" "''${license}"

    echo "Done! model-viewer ''${version} updated."
  '';
}
