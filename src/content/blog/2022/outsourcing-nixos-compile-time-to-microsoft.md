---
title: Outsourcing NixOS compile time to Microsoft
date: '2022-10-10T20:00:00+0100'
url: /blog/2022/10/outsourcing-nixos-compile-time-to-microsoft/
tags: [NixOS, Nix, Linux, Cachix, GitHub Actions]
---

[NixOS](https://nixos.org/) is a Linux-distribution that may be source-based, but it has a binary
cache that covers things so you generally don't need to compile things,
things tends to be cached.

However, depending on how you configure your system, you may trigger compiles
depending on what you do.

So a thing I do is that I run Emacs 29 with the native-comp patches that is
wayland native with the pgtk-branch. This is by no mean the stable Emacs
release at the point of writing. So to get this Emacs I use the excellent
[nix-community/emacs-overlay](https://github.com/nix-community/emacs-overlay) (that is maintained by my friend
[@adisbladis](https://github.com/adisbladis)). However, this means that I will get Emacs from a development
branch of Emacs, then I need to build all the Emacs packages that I use in my
configuration as well for this version of Emacs.

Emacs with native comp is also quite slow to build. So building it… takes
time… and I need the Emacs built on two laptops for different use.

## My first approach (using a remote builder)

So I started by using my home server as a remote builder on both laptops,
this way… most of the time Emacs would be compiled on the remote builder… so
when one system had been updated and the second system would try to do the
same build on the same server… it would been cached there and not needed
building.

This was pretty simple, this didn't take much time to set up… but not a
proper binary cache and wouldn't always match due to the chance of not
running that build on the remote system.

However it worked for quite some time, but it had side-effects… like… when I
started the build I still had to wait for it to complete… and more notably
now compared to before. I'm the one paying the power draw for the home
server.

## Outsourcing the builds to Microsoft (using GitHub actions and cachix)

So with this I had to set up and use a proper binary cache, I decided to give
[cachix](https://cachix.org) a try (haven't managed it myself before). I must say it's really nice.
It's really easy to push builds there and then you have it as a binary cache
on your system and just get the pushed builds. It's also free to use for open
source projects and you can cache up to 5GiB data (and it won't cache things
that are in the cache.nixos.org cache) so it's really plenty enough for me.

So first, go to cachix, then you need to configure your systems to use cachix
like this:

```nix
{
  # …

  nix.settings.substituters = [
    "https://YOURNAME.cachix.org"
  ];

  nix.settings.trusted-public-keys = [
    "YOURNAME.cachix.org-…"
  ];

  # …
}
```

### Caching all systems on your main branch

This is really quite simple, you create a [Personal Access Token](https://app.cachix.org/personal-auth-tokens) at cachix and
then you create a GitHub workflow in your repository. So I just created the
file named `.github/workflows/cachix.yml`:

```yaml
name: Cachix

on:
  push:
    branches:
      - main

jobs:
  build:
    runs-on: ubuntu-20.04
    steps:
      # Clone repo
      - uses: actions/checkout@v3
        with:
          submodules: recursive
      # Install nix
      - uses: cachix/install-nix-action@v18
      - name: Cachix setup
        uses: cachix/cachix-action@v12
        with:
          name: YOURNAME
          # you need to create the secret named CACHIX_AUTH_TOKEN
          # with the personal access token created.
          authToken: '${{ secrets.CACHIX_AUTH_TOKEN }}'
          skipPush: true

      # Build a configuration.nix file that doesn't use flakes
      # and push to cachix.
      - name: Build private-laptop system derivation
        run: nix-build '<nixpkgs/nixos>' -I nixos-config=./hosts/private-laptop/configuration.nix -I nixpkgs=./nix/nixos-unstable -A system
      - name: Cache private-laptop system derivation
        run: realpath result | cachix push YOURNAME

      # Add additional builds here…
```

This should be enough to make sure that you always have a cached main branch.

## Automating updates of the main branch

This looks quite similar to the above, but it runs on a schedule and has an
additional step, which is to update nixpkgs and all other dependencies.

So I have a file named `.github/workflows/update.ym`

```yaml
name: Update

on:
  schedule:
    - cron: "30 3 * * 1,3,6" # At 03:30 on Monday, Wednesday, and Saturday.

jobs:
  build:
    runs-on: ubuntu-20.04
    steps:
      # Clone repo
      - uses: actions/checkout@v3
        with:
          submodules: recursive
      # Install nix
      - uses: cachix/install-nix-action@v18
      - name: Cachix setup
        uses: cachix/cachix-action@v12
        with:
          name: YOURNAME
          # you need to create the secret named CACHIX_AUTH_TOKEN
          # with the personal access token created.
          authToken: '${{ secrets.CACHIX_AUTH_TOKEN }}'
          skipPush: true

      # Do updates of nixpkgs and other dependencies.
      - name: Update all dependencies
        run: nix-shell --run 'make update-all'
        env:
          NIX_PATH: nixpkgs=./nix/nixos-unstable

      # Build a configuration.nix file that doesn't use flakes
      # and push to cachix.
      - name: Build private-laptop system derivation
        run: nix-build '<nixpkgs/nixos>' -I nixos-config=./hosts/private-laptop/configuration.nix -I nixpkgs=./nix/nixos-unstable -A system
      - name: Cache private-laptop system derivation
        run: realpath result | cachix push YOURNAME

      # Add additional builds here…

      # Finish up by commiting the changes if all builds worked.
      - uses: stefanzweifel/git-auto-commit-action@v4.15.0
        with:
          commit_message: "cron(treewide): Upgrade systems"
```

### But wait, you have encrypted secrets in your repo

Yes, that's correct and I don't give GitHub a key to decrypt that or cache it
in cachix, however, I store those secrets in a file name `.data-secrets.nix`
in the root of the repo on my laptops. Then I read from that file when I
build. So what I do is that I added the following step before the builds on
GitHub:

```yaml
      # Populate a fake secrets file.
      - name: Populate a fake secrets file
        run: echo '{ hashedEtuPassword = ""; }' > .data-secrets.nix
```

This way the build will at least find empty strings and the keys will contain
something. So all the builds will succeed. This also means that it won't
cache all the things fully or properly. However, my secrets contains things
like hashed passwords and that shouldn't trigger any big compiles. So having
to build those things locally and symlink together the rest of the system
isn't a big deal.
