{ pkgs, ... }:
pkgs.writeShellApplication {
  name = "update-fontawesome";
  runtimeInputs = [pkgs.curl pkgs.jq pkgs.unzip];
  text = ''
    root="$(git rev-parse --show-toplevel)"

    if [ $# -eq 1 ]; then
      version="$1"
    else
      echo "Fetching latest FontAwesome release..."
      tag=$(curl -sf "https://api.github.com/repos/FortAwesome/Font-Awesome/releases/latest" | jq -r '.tag_name')
      version="''${tag#v}"
    fi

    url="https://use.fontawesome.com/releases/v''${version}/fontawesome-free-''${version}-web.zip"
    echo "Downloading FontAwesome ''${version}..."

    tmpdir=$(mktemp -d)
    trap 'rm -rf "''${tmpdir}"' EXIT

    curl -sL "''${url}" -o "''${tmpdir}/fontawesome.zip"

    echo "Extracting..."
    unzip -q "''${tmpdir}/fontawesome.zip" -d "''${tmpdir}/extracted"
    base="''${tmpdir}/extracted/fontawesome-free-''${version}-web"

    echo "Copying SCSS files..."
    cp "''${base}/scss/"*.scss "''${root}/themes/albatross/assets/scss/fontawesome/"

    echo "Copying webfonts..."
    cp \
      "''${base}/webfonts/fa-solid-900.ttf" \
      "''${base}/webfonts/fa-solid-900.woff2" \
      "''${base}/webfonts/fa-brands-400.ttf" \
      "''${base}/webfonts/fa-brands-400.woff2" \
      "''${root}/themes/albatross/static/fonts/fontawesome/"

    echo "Done! FontAwesome ''${version} updated."
  '';
}
