# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Personal website/blog for [elis.nu](https://elis.nu), built with Hugo and managed entirely through Nix flakes. Deployed to GitHub Pages.

## Commit Messages

Use [Conventional Commits](https://www.conventionalcommits.org/): `type(scope): description`. Common types: `feat`, `fix`, `post`, `chore`, `cron`. Examples from this repo: `post: NixOS remote unlock of encrypted ZFS over SSH`, `cron(flake): Update inputs`.

## Commands

```bash
nix run .          # Local dev server at http://localhost:1313/ (sets up 3D models)
nix build          # Production build to ./result/
nix fmt            # Format Nix files with alejandra
nix flake check    # Validate flake configuration
nix run .#update-3d-models  # Update 3D models release URL and hash
```

CI also runs `deadnix` and `statix` for Nix linting. There is no test suite.

## Architecture

Everything is defined in `flake.nix`:
- `packages.default` — Hugo build using `src = ./.`; installs 3D model assets then runs `hugo --minify`
- `packages._3dmodelsPage` — fetches pre-built release tarball from `github:etu/3d-models`, uses `jq` to generate `content/3d-models.md` and copies model files to `static/3d-models/`
- `apps.default` — dev server that installs 3D models then runs `hugo server`
- `apps.update-3d-models` — queries GitHub API for latest 3d-models release, updates URL and hash in `flake.nix`

**Hugo is pinned via nixpkgs** and bundled with `dart-sass` (required for SCSS compilation) using `symlinkJoin`. The theme and all its static dependencies are vendored directly in this repo. The only Nix inputs are `nixpkgs` and `flake-utils`.

**3D models** are consumed as a pre-built GitHub release from `github:etu/3d-models` (not a flake input). `_3dmodelsRelease` fetches the tarball via `pkgs.fetchzip` with a pinned URL and hash. Releases are tagged `YYYY-MM-DD-<short-sha>`. Run `nix run .#update-3d-models` to update.

## Vendored Resources

These external resources are committed directly to the repo. To update them, re-fetch manually and commit the result.

| Resource | Location | Source |
|---|---|---|
| Hugo theme | `themes/albatross/` | `github:etu/hugo-theme-albatross` — copy `src/` from that repo |
| ISO flag SVGs | `themes/albatross/static/img/iso-flags/` | `github:etu/web-iso-flags` — only `se.svg` and `gb.svg` are used |
| model-viewer.min.js | `themes/albatross/static/js/` | https://ajax.googleapis.com/ajax/libs/model-viewer/3.4.0/model-viewer.min.js — see `model-viewer.LICENSE` |
| AnimCubeJS | `themes/albatross/static/js/` | See `AnimCubeJS.LICENSE` |
| FontAwesome 6.5.1 SCSS | `themes/albatross/assets/scss/fontawesome/` | https://use.fontawesome.com/releases/v6.5.1/fontawesome-free-6.5.1-web.zip — only `solid` and `brands` webfonts are used |
| FontAwesome 6.5.1 webfonts | `themes/albatross/static/fonts/fontawesome/` | Same zip — only `fa-solid-900` and `fa-brands-400` (ttf + woff2) |
| 3D model assets | fetched at build time | GitHub release from `github:etu/3d-models` — run `nix run .#update-3d-models` |

## Content Structure

- `content/blog/` — posts organized by year (`2019/` … `2026/`)
- `content/` — top-level pages: `about.md`, `work.md`, `talks.md`, `cubing/`, `3d-models.md` (auto-generated)
- Bilingual (English + Swedish): Swedish pages use `.sv.md` suffix or `_index.sv.md`
- `config.yaml` — Hugo config (base URL, theme name, menus, Matomo analytics, language settings)
- `themes/albatross/` — vendored theme including all layouts, SCSS, and static assets
