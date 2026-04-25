---
title: 'NixOS ❄: Remote unlock of encrypted ZFS over SSH'
date: '2026-04-24T00:00:00+0200'
url: /blog/2026/04/nixos-zfs-remote-unlock-over-ssh/
tags: [NixOS, Linux, ZFS]
---

This is a follow-up to my earlier post: [Encrypted ZFS mirror with mirrored
boot on NixOS](/blog/2019/08/encrypted-zfs-mirror-with-mirrored-boot-on-nixos/).

At the end of that post I briefly mentioned that I configured remote unlocking
of my encrypted ZFS pools over SSH on boot, linking off to the NixOS wiki. The
wiki page is now quite outdated and the approach it describes no longer works
well with modern NixOS, which uses a systemd-based initrd by default. This post
covers the current way to do it.

## What changed

The old approach involved writing a script to `/root/.profile` that would run
`zfs load-key -a` on SSH login. This worked with the old stage-1 initrd, but
with the systemd initrd it breaks in two ways:

1. Root's home directory in the systemd initrd is `/var/empty`, not `/root`,
   so `.profile` was never sourced.
2. After loading keys manually with `zfs load-key -a`, running `systemctl
   default` to advance the boot would trigger systemd's own `zfs-load-key`
   services, which send password prompts to the *physical console* through the
   `systemd-ask-password` mechanism — not to your SSH session. So you'd see
   password prompts but entering anything would have no effect.

## The correct approach

The right tool for the job is `systemd-tty-ask-password-agent`. When systemd
wants to ask for a passphrase (e.g. from a `zfs-load-key@pool.service` unit),
it queues the request through its ask-password mechanism. Running
`systemd-tty-ask-password-agent` on your SSH terminal intercepts those queued
requests and routes the prompts — and your answers — back through systemd
properly. No manual key loading, no `systemctl default` needed. Systemd
continues the boot naturally once all keys are provided.

The `--watch` flag is important if you have more than one encrypted pool.
`--query` only handles *currently pending* requests and exits. With two pools
(e.g. `zroot` and `zstorage`), the second pool's key request only becomes
pending after the first is answered, so `--query` would miss it. `--watch`
stays running and catches each request as it appears.

## Configuration

Here is the relevant NixOS configuration. This goes in your
`hardware-configuration.nix` or wherever you keep your host-specific boot
settings.

```nix
{...}: {
  boot.initrd = {
    availableKernelModules = [
      # ... your kernel modules ...

      # Make sure your network card's kernel module is listed here,
      # otherwise the initrd won't have network access.
      "r8169"  # Example: Realtek NIC
    ];

    network.enable = true;

    # Start an SSH server in the initrd on port 2222.
    network.ssh = {
      enable = true;
      port = 2222;
      hostKeys = [
        # A host key that lives in persistent storage, separate from
        # your regular SSH host key. You don't want to share host keys
        # between the initrd and the booted system.
        "/path/to/initrd-ssh-host-key"
      ];
      authorizedKeys = [
        "ssh-ed25519 AAAA... your-public-key"
      ];
    };
  };

  # Write a .profile to /var/empty (root's home in the systemd initrd)
  # so that logging in over SSH automatically starts the password agent.
  boot.initrd.systemd.services.zfs-setup-root-profile = {
    description = "Prepare root .profile for ZFS unlocking via SSH";
    wantedBy = [ "initrd.target" ];
    before = [ "initrd-root-fs.target" ];
    unitConfig.DefaultDependencies = false;
    script = ''
      mkdir -p /var/empty
      echo "systemd-tty-ask-password-agent --watch" > /var/empty/.profile
    '';
    serviceConfig.Type = "oneshot";
  };
}
```

A few things worth noting:

- The `>` (not `>>`) matters. Using `>>` would accumulate entries in
  `.profile` across reboots.
- Root's home in the systemd initrd is `/var/empty`. Writing to `/root/.profile`
  has no effect because that is not where bash looks.
- The host key for the initrd should be a separate key from the one your booted
  system uses. This avoids SSH "host key changed" warnings every time the system
  reboots. On NixOS I manage this with agenix.

## Using it

When the server boots and is waiting for the ZFS passphrases, SSH in on port
2222:

```sh
ssh root@your-server -p 2222
```

The `.profile` runs immediately on login and you will be prompted for each pool's
passphrase in turn:

```
🔐 Enter key for zpool1:
🔐 Enter key for zpool2:
```

After the last key is entered the SSH session closes as the initrd hands off to
the booted system. That's it.
