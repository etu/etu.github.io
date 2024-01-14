#! /usr/bin/env nix-shell
#! nix-shell -i bash -p xdg_utils

set -euo pipefail

# Install the fontawesome files
rm -rf src/themes/elisnu/assets/scss/fontawesome src/themes/elisnu/static/fonts/fontawesome
mkdir -p src/themes/elisnu/assets/scss/fontawesome src/themes/elisnu/static/fonts/fontawesome
install -m 644 -D $(nix build .#fontawesome --print-out-paths --no-link)/scss/* -t src/themes/elisnu/assets/scss/fontawesome
install -m 644 -D $(nix build .#fontawesome --print-out-paths --no-link)/webfonts/* -t src/themes/elisnu/static/fonts/fontawesome

# Navigate to directory
cd src/

# Open browser
sleep 1 && xdg-open "http://localhost:1313/" &

# Run pinned version of hugo
nix run .#hugo -- server --logLevel debug --disableFastRender
