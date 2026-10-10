---
title: Simple deployments of NixOS machines with nixus
date: '2021-07-23T16:30:00+0100'
url: /blog/2021/07/simple-deployments-of-nixos-machines/
tags: [NixOS, Nix, Linux, nixus]
---

Since I've started using NixOS about four years ago I haven't really used any
tools to do central deployments of machines. But I've always read and known
that NixOS is excellent at this. NixOS can easily build another systems
configuration, then copy the system to the target systems nix store and then
activate it there.

Despite knowing all this, I haven't gotten around to doing this centrally. A
while ago the need for this changed because one of my VPSes started running
low on RAM, low enough to not be able to build new generations of it's own
system. Which posed a problem for future upgrades. One way to solve it would
be to pay more money for resources that aren't really needed except from when
doing system upgrades. The other way would be to push pre-built systems from
another location. Using the second way is simpler and fixes the issue.

There's many ways to achieve remote deployments, one of the main and most
mentioned one within NixOS is [NixOps](https://github.com/NixOS/nixops), this is because it's the “official”
tool to do this. But I've chose to avoid this due to the required state with
it's database to keep track of remote hosts.

Then there's something called [morph](https://github.com/DBCDK/morph) that seems fairly commonly used as well.
The one I'd liked the most was [nixus](https://github.com/Infinisil/nixus). Partly due to it's simplicity, the
support to do rollbacks on failed activation or failure to access the system
right after activation to make sure that you'd never lock yourself out, multi
system management and it's own secrets support.

## Pulling in the nixus module using `niv`

I've use `niv` to pull in the nixus modules:

```sh
niv add Infinisil/nixus
```

If you haven't used `niv` before it will create a folder called `nix/` in
your current directory. This folder will contain a `sources.nix` file which
parses a file called `sources.json` which contains the repositories managed
by `niv` and which git commit they are locked to.

## Setting up a deployment file using nixus

This is also fairly straightforward, it needs to import the nixus module from
niv to then use it to declare a nixus module.

So what you need to look out for here is the relative path to the niv file
`sources.nix` to import the niv sources.

Then you have to look out for the nixpkgs include in the defaults block, I
have a checkout that I use for all the systems to have the same version of
everything on all systems. Then I move all systems forward at the same time
when I do upgrades.

```nix
let
  # Load niv sources
  sources = import ../nix/sources.nix;

  # Import the nixus module
  nixus = import "${sources.nixus}/default.nix" { };
in
nixus ({ config, ... }: {
  # Set a nixpkgs version for all nodes
  defaults = { ... }: {
    # Use a local nixpkgs checkout
    nixpkgs = ../nix/nixos-unstable;

    # Alternative: Fetch nixpkgs with fetch tarball
    nixpkgs = fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/tarball/16fc531784ac226fb268cc59ad573d2746c109c1";
      sha256 = "0qw1jpdfih9y0dycslapzfp8bl4z7vfg9c7qz176wghwybm4sx0a";
    };
  };

  nodes.node1 = { lib, config, ... }: {
    # How to reach this node
    host = "root@node1.example.org";

    # What configuration it should have
    configuration = ../hosts/node1/configuration.nix;
  };

  nodes.node2 = { lib, config, ... }: {
    # How to reach this node
    host = "root@node2.example.org";

    # What configuration it should have
    configuration = ../hosts/node2/configuration.nix;
  };
})
```

## Building and deploying systems

Building and deploying your system couldn't be simpler! It's as easy as
running `nix-build path/to/deployment.nix` where the path is to the file that
I had an example of above. When the build is done you'll have a result
symbolic link in the folder you were executing the command from. This results
output is a shell script that will run the deploy. So just go ahead and run
`./result` to deploy to all the nodes defined in that file.
