_default:
    @just --list

run:
    hugo server --logLevel debug --disableFastRender --gc

compute-colors CONFIG="config.yaml":
    nix run .#compute-colors -- {{CONFIG}}

update-3d-models:
    nix run .#update-3d-models

update-fontawesome VERSION="":
    nix run .#update-fontawesome {{ if VERSION != "" { "-- " + VERSION } else { "" } }}

update-model-viewer VERSION="":
    nix run .#update-model-viewer {{ if VERSION != "" { "-- " + VERSION } else { "" } }}
