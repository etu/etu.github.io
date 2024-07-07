---
title: 'Prune gh-pages branches using GitHub Actions'
date: '2024-07-07T11:30:00+0200'
tags: [GitHub, GitHub Actions]
---

This website is hosted on GitHub Pages, built using nix and hugo with
a custom theme that I maintain. I have automated updates for the nix
flake to get new versions of hugo and nixpkgs, which applies to both
my theme and the website itself.

This automation generates numerous commits and deployments to the
gh-pages branch, mainly due to minor version bumps of hugo and other
changes to the theme. While this hasn’t been a problem for my static
website, which primarily consists of text, a recent addition has
created some challenges.

I added a page for my [./3d-models/](/3d-models/) containing `.3mf`,
`.stl`, and `.glb` files. These binary files are not always
reproducible, particularly with updates to nixpkgs that affect
openscad and blender, which I use to create glb files from openscad
sources. Consequently, the repository size has been growing
continuously.

## Identifying the problem

Recently, while on a coffee shop WiFi, I attempted a `git pull` that
took too long to complete before I had to leave. This event
highlighted the growing size of my repository and prompted me to find
a solution.

## Solution: Pruning the gh-pages branch

To address this, I decided to prune the gh-pages branch by squashing
commits. However, I wanted to retain the latest commits separately to
easily track recent changes in case of unexpected issues.

Initially, I considered writing a script for this task, but I found an
existing action,
[`myactionway/branch-pruner-action`](https://github.com/myactionway/branch-pruner-action),
which simplifies the process.

Here’s my workflow for pruning the branch:
`.github/workflows/squash.yml`

```yaml
---
name: 'Squash gh-pages'

env:
  NEW_FIRST_COMMIT: HEAD~19
  DEFAULT_BRANCH: 'gh-pages'

'on':
  workflow_dispatch:
  schedule:
    - cron: '47 7 * * 2'  # At 07:47 on Tuesday.

jobs:
  squash-gh-pages-branch:
    runs-on: ubuntu-22.04
    permissions:
      contents: write
    steps:
      - uses: actions/checkout@v4
        with:
          ref: ${{ env.DEFAULT_BRANCH }}
          fetch-depth: 0

      - uses: myactionway/branch-pruner-action@v2.0
        with:
          new_first_commit: ${{ env.NEW_FIRST_COMMIT }}
          branch: ${{ env.DEFAULT_BRANCH }}
```

This workflow runs weekly or can be triggered manually. It keeps the
19 most recent commits, squashing the rest into a single commit
representing the entire previous history.

## Results

Before squashing, the repository size from this API call was:

```sh
$ curl -s https://api.github.com/repos/etu/etu.github.io | jq '.size'
386904
```

After squashing the gh-pages branch, it reduced to:

```sh
$ curl -s https://api.github.com/repos/etu/etu.github.io | jq '.size'
296830
```

This shows a reduction from approximately 386 MiB to 296 MiB. However,
I believe GitHub can further optimize the repository size internally.

Upon inspecting my local clone of the repository, it was about 680 MiB
before the squash. After running `git gc --aggressive --prune=now`, it
shrank to about 354 MiB.
