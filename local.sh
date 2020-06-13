#! /usr/bin/env nix-shell
#! nix-shell -i bash -p python3 xdg_utils firefox

nix-build -j 20

if test -L result
then
   # Sleep a second and then open the browser
   sleep 1 && xdg-open "http://localhost:8000/" &

   cd result/ && python -m http.server
fi
