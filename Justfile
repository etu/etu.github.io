_default:
    @just --list

run:
    hugo server --logLevel debug --disableFastRender --gc

# hugo server renders in-memory and never sees a real public/ dir, so
# pagefind has to index a real build first; copying its output into
# static/ is what makes hugo server (and `just run`) actually serve it.
search-index:
    hugo --minify
    rm -rf static/pagefind
    pagefind --site public --output-path static/pagefind

compute-colors CONFIG="config.yaml":
    nix run .#compute-colors -- {{CONFIG}}

validate-colors CONFIG="config.yaml":
    nix run .#compute-colors -- --validate {{CONFIG}}

update-3d-models:
    nix run .#update-3d-models

update-fontawesome VERSION="":
    nix run .#update-fontawesome {{ if VERSION != "" { "-- " + VERSION } else { "" } }}

update-model-viewer VERSION="":
    nix run .#update-model-viewer {{ if VERSION != "" { "-- " + VERSION } else { "" } }}
