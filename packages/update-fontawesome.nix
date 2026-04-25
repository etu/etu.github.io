{ pkgs, ... }:
pkgs.writeShellApplication {
  name = "update-fontawesome";
  runtimeInputs = [pkgs.curl pkgs.unzip];
  text = ''
    if [ $# -ne 1 ]; then
      echo "Usage: update-fontawesome VERSION"
      echo "Example: update-fontawesome 6.5.1"
      exit 1
    fi

    version="$1"
    root="$(git rev-parse --show-toplevel)"
    url="https://use.fontawesome.com/releases/v''${version}/fontawesome-free-''${version}-web.zip"

    tmpdir=$(mktemp -d)
    trap 'rm -rf "''${tmpdir}"' EXIT

    echo "Downloading FontAwesome ''${version}..."
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
