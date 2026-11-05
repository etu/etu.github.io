---
title: 'NixOS ❄: Remote unlock of encrypted ZFS over Tailscale'
date: '2026-11-03T22:00:00+0100'
tags: [NixOS, Linux, ZFS, Tailscale]
---

This is a follow-up to my earlier post: [Remote unlock of encrypted ZFS
over SSH](/blog/2026/04/nixos-zfs-remote-unlock-over-ssh/).

That setup has one limitation: the SSH server in the initrd is only
reachable on my local network. If my file server reboots while I'm
away, for a power cut or a kernel update, it just sits there waiting
for passphrases until I get home. I could forward a port on my router,
but I really don't want an SSH server exposed to the internet, and
certainly not one running in an initrd.

All my machines are already on [Tailscale](https://tailscale.com/), so
the obvious solution is to have the initrd join the tailnet as well.

## The idea

The initrd joins the tailnet as its own node, `server-main-elis-initrd`,
separate from the booted system's `server-main-elis`. It has its own
identity, its own address and its own name, which has a few nice
consequences:

- The booted system's Tailscale state stays on the encrypted pool where
  it belongs, the initrd never needs it.
- The two nodes can have different ACLs. The initrd only needs to
  accept SSH, it never needs to connect to anything.
- Since it's a separate host, the initrd's SSH server can listen on the
  normal port 22 without colliding with anything on the tailnet.

There is no ready-made NixOS option for this, but with the systemd
initrd it's just one extra service.

## Registering the node

The initrd can't do an interactive login, so the node is registered
once beforehand and its state file is then baked into the initrd. I
did this on the server itself, next to its regular `tailscaled`.

First, allow yourself to assign a tag to it in the Tailscale ACL policy:

```jsonc
"tagOwners": {
  "tag:initrd": ["autogroup:admin"],
},
```

Tagged devices have key expiry disabled by default, which is exactly
what we want here. Otherwise the initrd would get locked out of the
tailnet after a few months.

Then start a second `tailscaled` with its own state directory and
socket, using userspace networking and a random UDP port so it doesn't
collide with the one that is already running:

```sh
mkdir -p /root/initrd-ts
tailscaled \
  --tun=userspace-networking \
  --port=0 \
  --statedir=/root/initrd-ts \
  --state=/root/initrd-ts/tailscaled.state \
  --socket=/root/initrd-ts/tailscaled.sock
```

In another terminal, bring it up with the hostname and the tag:

```sh
tailscale --socket=/root/initrd-ts/tailscaled.sock up \
  --hostname=server-main-elis-initrd \
  --advertise-tags=tag:initrd
```

Open the login URL it prints and approve the node. Then stop
`tailscaled` with Ctrl-C. **Don't** run `tailscale logout`, that
invalidates the node key and the state file becomes useless.

What's left is `/root/initrd-ts/tailscaled.state`, which contains the
node's identity, including the hostname and tag. I encrypted it with
[agenix](https://github.com/ryantm/agenix), like the initrd SSH host
key, and removed the plaintext copies.

## Configuration

The state file goes into the initrd with `boot.initrd.secrets`, which
copies it in when the bootloader is installed. Then a service starts
`tailscaled` in the initrd:

```nix
{ config, lib, pkgs, ... }: {
  # Decrypted by agenix on the booted system, then copied into the
  # initrd when the bootloader is installed.
  age.secrets.initrd-tailscaled-state = {
    file = ./secrets/initrd-tailscaled-state.age;
    path = "/persistent/etc/initrd/tailscaled.state";
    symlink = false;
  };

  boot.initrd.secrets."/var/lib/tailscale/tailscaled.state" =
    config.age.secrets.initrd-tailscaled-state.path;

  # Only the Go binary goes into the initrd, see below.
  boot.initrd.systemd.extraBin =
    let
      tailscaled = pkgs.runCommand "tailscaled-initrd" { } ''
        install -Dm755 ${pkgs.tailscale}/bin/.tailscaled-wrapped $out/bin/tailscaled
      '';
    in
    {
      tailscaled = "${tailscaled}/bin/tailscaled";
      # It's a multicall binary, called as tailscale it's the CLI.
      tailscale = "${tailscaled}/bin/tailscaled";
    };

  boot.initrd.systemd.services.tailscaled = {
    description = "Tailscale node agent in the initrd";
    wantedBy = [ "initrd.target" ];
    after = [ "network.target" ];
    # Stop before switching root, so the real tailscaled starts cleanly.
    conflicts = [ "initrd-switch-root.target" ];
    before = [ "initrd-switch-root.target" ];
    unitConfig.DefaultDependencies = false;
    serviceConfig = {
      ExecStart = lib.concatStringsSep " " [
        "/bin/tailscaled"
        "--tun=userspace-networking"
        "--statedir=/var/lib/tailscale"
        "--state=/var/lib/tailscale/tailscaled.state"
      ];
      Restart = "on-failure";
    };
  };

  # And move the initrd SSH server to the normal port.
  boot.initrd.network.ssh.port = 22;
}
```

This builds on the configuration from the previous post, which sets up
networking, the SSH server and the password agent in the initrd.

### Deploy the secret first

There's a chicken and egg problem in the configuration above.
`boot.initrd.secrets` reads the decrypted state file from the booted
system when the bootloader is installed. But when switching to a new
configuration, NixOS installs the bootloader *before* it runs the
activation, which is where agenix decrypts the secrets. So on the
first deploy the file doesn't exist yet, and installing the bootloader
fails.

The solution is to deploy in two steps. First deploy only the
`age.secrets.initrd-tailscaled-state` part, so the decrypted file is
in place. Then add `boot.initrd.secrets` and the `tailscaled` service
and deploy again.

### Userspace networking

With `--tun=userspace-networking`, `tailscaled` runs its own network
stack instead of creating a `tailscale0` interface. This means the
initrd needs no `tun` kernel module and no firewall rules, and incoming
connections from the tailnet are simply forwarded to the same port on
localhost, where the initrd's SSH server is listening.

### Only the binary

The `tailscale` package in nixpkgs wraps `tailscaled` to put `iptables`,
`iproute2` and a few other tools in its `PATH`. Those are only needed
for the kernel networking mode, so I copy the unwrapped Go binary into
its own derivation to keep them out of the initrd.

### The store path gotcha

My first attempt referenced the binary directly in `ExecStart`, which
is what you'd normally do in a systemd service on NixOS. It built just
fine, but on boot the initrd journal said:

```text
tailscaled.service: Unable to locate executable '/nix/store/…-tailscaled-initrd/bin/tailscaled': No such file or directory
tailscaled.service: Failed with result 'exit-code'.
```

Store paths that are only referenced from a unit in the systemd initrd
are *not* copied into it. They have to be added explicitly, with
`boot.initrd.systemd.storePaths` or, as above, with
`boot.initrd.systemd.extraBin`, which also puts them in `/bin`. Having
`tailscale` in `/bin` is handy too, it lets you run `tailscale status`
from the initrd shell when debugging.

### Port 22

In the previous post the initrd SSH server listened on port 2222, so it
didn't share an address and port with the booted system's SSH server
but with a different host key. Over Tailscale that's no longer an
issue, since the initrd is its own host.

On the local network the address is still shared, so it will present
either the initrd's or the booted system's host key depending on the
boot stage. OpenSSH accepts any of the keys listed for a host, so I
list both keys for the LAN address in `programs.ssh.knownHosts`. On
machines where known hosts aren't managed, add the initrd's key by hand
once, otherwise SSH refuses to connect with the scary "REMOTE HOST
IDENTIFICATION HAS CHANGED" warning.

## Locking it down

The state file is copied into the initrd, and the initrd lives
unencrypted on the boot partition. So anyone with access to the disk
can read it and join the tailnet as `server-main-elis-initrd`. The
initrd SSH host key has exactly the same problem, it's inherent to
running anything before the disks are unlocked.

That's where the tag comes in. Only allow incoming SSH to it, and
nothing from it:

```jsonc
"acls": [
  // ...
  { "action": "accept", "src": ["autogroup:member"], "dst": ["tag:initrd:22"] },
],
```

Since no rule has `tag:initrd` as its source, a stolen state file only
gets you a node that can be reached on port 22, and can't reach
anything itself.

## Using it

When the server boots and is waiting for the ZFS passphrases, SSH to
the initrd's node from anywhere on the tailnet:

```sh
ssh root@server-main-elis-initrd
```

The password agent from the previous post starts right away and
prompts for each pool's passphrase. Once the last one is entered, the
initrd stops its `tailscaled`, switches to the real root and the
booted system comes up as `server-main-elis` on the tailnet. The
initrd node then just shows as offline until the next reboot.
