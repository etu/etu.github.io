# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Personal website/blog for [elis.nu](https://elis.nu), built with Hugo and managed entirely through Nix flakes. Deployed to GitHub Pages.

## Commit Messages

Use [Conventional Commits](https://www.conventionalcommits.org/): `type(scope): description`. Common types: `feat`, `fix`, `post`, `chore`, `cron`. Examples from this repo: `post: NixOS remote unlock of encrypted ZFS over SSH`, `cron(flake): Update inputs`.

## Commands

```bash
nix run .          # Local dev server at http://localhost:1313/ (sets up theme + 3D models)
nix build          # Production build to ./result/
nix fmt            # Format Nix files with alejandra
nix flake check    # Validate flake configuration
```

CI also runs `deadnix` and `statix` for Nix linting. There is no test suite.

## Architecture

Everything is defined in `flake.nix`:
- `packages.default` — Hugo build that symlinks the theme and installs 3D model assets before running `hugo`
- `packages.theme` — the theme files from `github:etu/hugo-theme-albatross`, exposed as `tpkgs.theme`
- `packages._3dmodelsPage` — derived from `github:etu/3d-models`; builds a markdown file with JSON front matter and copies `.3mf`/`.glb` files, installed as `content/3d-models.md` + `static/3d-models/*`
- `apps.default` — dev server that builds theme and 3D models via `nix build`, symlinks/installs them into `src/`, then runs `hugo server`

The Hugo source lives entirely under `src/`. The theme is **not** committed; it is fetched as a flake input and symlinked at build/run time.

**Hugo is pinned via nixpkgs** and bundled with `dart-sass` (required for SCSS compilation) using `symlinkJoin`. The theme and all its static dependencies (FontAwesome, flag SVGs, model-viewer) are vendored directly in this repo. The only remaining Nix inputs beyond nixpkgs are `flake-utils` and `_3dmodels` (which shares `flake-utils` via `follows`).

## Vendored Resources

These external resources are committed directly to the repo. To update them, re-fetch manually and commit the result.

| Resource | Location | Source |
|---|---|---|
| Hugo theme | `src/themes/albatross/` | `github:etu/hugo-theme-albatross` — copy `src/` from that repo |
| ISO flag SVGs | `src/static/img/iso-flags/` | `github:etu/web-iso-flags` — only `se.svg` and `gb.svg` are used |
| model-viewer.min.js | `src/static/js/model-viewer.min.js` | https://ajax.googleapis.com/ajax/libs/model-viewer/3.4.0/model-viewer.min.js — re-download to update |
| FontAwesome 6.5.1 SCSS | `src/themes/albatross/assets/scss/fontawesome/` | https://use.fontawesome.com/releases/v6.5.1/fontawesome-free-6.5.1-web.zip — only `solid` and `brands` webfonts are used |
| FontAwesome 6.5.1 webfonts | `src/themes/albatross/static/fonts/fontawesome/` | Same zip — only `fa-solid-900` and `fa-brands-400` (ttf + woff2) |

## Content Structure

- `src/content/blog/` — posts organized by year (`2019/` … `2026/`)
- `src/content/` — top-level pages: `about.md`, `work.md`, `talks.md`, `cubing/`, `3d-models.md` (auto-generated)
- Bilingual (English + Swedish): Swedish pages use `.sv.md` suffix or `_index.sv.md`
- `src/config.yaml` — Hugo config (base URL, theme name, menus, Matomo analytics, language settings)
- `src/layouts/` — custom layouts (currently only the cubing section)
- `src/static/` — static assets served as-is
