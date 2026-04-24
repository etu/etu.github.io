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

**Hugo is pinned through the theme flake** (`tpkgs.hugo`), not nixpkgs. To upgrade Hugo, update the `theme-albatross` input. Both `theme-albatross` and `_3dmodels` share this repo's `flake-utils` via `follows`.

## Content Structure

- `src/content/blog/` — posts organized by year (`2019/` … `2026/`)
- `src/content/` — top-level pages: `about.md`, `work.md`, `talks.md`, `cubing/`, `3d-models.md` (auto-generated)
- Bilingual (English + Swedish): Swedish pages use `.sv.md` suffix or `_index.sv.md`
- `src/config.yaml` — Hugo config (base URL, theme name, menus, Matomo analytics, language settings)
- `src/layouts/` — custom layouts (currently only the cubing section)
- `src/static/` — static assets served as-is
