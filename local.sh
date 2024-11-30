#! /usr/bin/env nix-shell
#! nix-shell -i bash -p xdg-utils

set -euo pipefail

# Build the theme for the spcified page and place the symlink in the correct location.
nix build .#theme --out-link src/themes/$(nix eval .#theme.theme-name --raw)

# Build the 3d model page
rm -rf src/static/3d-models src/content/3d-models.md
mkdir -p src/static/3d-models
install -m 644 -v $(nix build .#_3dmodelsPage --print-out-paths --no-link)/index.md src/content/3d-models.md
install -m 644 -v -D $(nix build .#_3dmodelsPage --print-out-paths --no-link)/static/* -t src/static/3d-models

# Navigate to directory
cd src/

# Open browser
sleep 1 && xdg-open "http://localhost:1313/" &

# Run pinned version of hugo
nix run .#hugo -- server --logLevel debug --disableFastRender --gc
