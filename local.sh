#! /usr/bin/env nix-shell
#! nix-shell -i bash -p python3 xdg_utils firefox

#
# Usage:
# ./local.sh [optional source or web path]
#
# Example:
# ./local.sh src/blog/hello-world
#

nix build .#

if test -L result
then
    # Strip src/ from page path and replace .org extension with .html
    page_path=$(echo $1 | sed -e 's#^src/##' -e 's#.org$#.html#')

    # Sleep a second and then open the browser
    sleep 1 && xdg-open "http://localhost:8000/$page_path" &

    # Launch web server
    cd result/ && python -m http.server && cd -

    # Remove symlink
    rm result
fi
