#! /usr/bin/env nix-shell
#! nix-shell -i bash -p xdg_utils

set -euo pipefail

# Build the theme for the spcified page and place the symlink in the correct location.
nix build .#theme --out-link src/themes/$(nix eval .#theme.theme-name --raw)

# Navigate to directory
cd src/

# Open browser
sleep 1 && xdg-open "http://localhost:1313/" &

# Run pinned version of hugo
nix run .#hugo -- server --logLevel debug --disableFastRender --minify
