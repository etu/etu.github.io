_default:
    @just --list

run:
    hugo server --logLevel debug --disableFastRender --gc

update-3d-models:
    nix run .#update-3d-models
