---
title: 'NixOS superpower: specialisations'
date: '2024-02-17T20:30:00+0100'
tags: [NixOS, Linux]
---

[NixOS](https://nixos.org/) has a lot of configurability and features. One
feature that I've known about for a while that I think is both really cool,
but also a bit lesser known is the ability to have declarative
[Specialisations](https://nixos.wiki/wiki/Specialisation). To me, this is a
superpower of NixOS that I have a hard time to see any other Linux
Distribution having.

## What's a Specialisation?

The name doesn't do it justice, it's a bit of a weird name for it. However
I couldn't come up with a better name for it either.

A `specialisation` is a way to have a configuration that is only used in a
specific context. This configuration is then available as a boot option
alongside the normal configuration generation.

By default, when you specify a specialisation, it will inherit the parent
configuration and give you the ability to specify your own configuration
options specific for that specialisation. Here it's also possible to
override the parent configuration by using `lib.mkForce` to undo options
in the parent configuration..

However, one can also choose to *not* inherit the parent configuration. This
would then require you to specify the whole configuration for the
specialisation from scratch. Including hardware options and mount options.
This is cool, but a bit too much in most cases.

## How to Use Specialisations

To illustrate, let's consider a basic NixOS setup with GNOME as the
desktop environment:

```nix
{ ... }:

{
  # …

  services.xserver.enable = true;
  services.xserver.desktopManager.gnome3.enable = true;

  # …
}
```

Suppose we want to create a specialisation to use KDE Plasma instead. We
can achieve this by adding the following:

```nix
{ lib, ... }:

{
  # …

  services.xserver.enable = true;
  services.xserver.desktopManager.gnome3.enable = true;

  specialisation.plasma = {
    # Disable GNOME
    services.xserver.desktopManager.gnome3.enable = lib.mkForce false;

    # Enable Plasma
    services.xserver.desktopManager.plasma5.enable = true;
  };

  # …
}
```

After defining the specialisation, it becomes available as a boot option.
When applying the configuration with `nixos-rebuild switch`, specify
`--specialisation plasma` to activate the Plasma specialisation.

## Real-world Use Case

Consider a scenario where you need to separate work and personal data on
your laptop, adhering to compliance requirements. Creating a
specialisation for your work environment with a separate ZFS dataset for
the home partition allows for distinct management of work-related data.

For instance, to override the home directory in the work specialisation:

```nix
{ lib, ... }:

{
  # …

  fileSystems."/home" = {
    device = "zroot/safe/home";
    fsType = "zfs";
  };

  specialisation.work = {
    fileSystems."/home".device = lib.mkForce "zroot/safe/work-home";
  };

  # …
}
```

This setup enables focused work environments with separate backups and
snapshots, facilitating data management and compliance adherence.

By leveraging NixOS specialisations, you can tailor your system
configurations to meet diverse requirements efficiently.

## Conclusion

NixOS specialisations offer a level of flexibility and customization
that's unmatched in the Linux world. By understanding how to leverage
this powerful feature, you can tailor your system configurations to
meet diverse requirements efficiently. Experiment with specialisations
in your NixOS setup and unlock a world of possibilities for
fine-tuning your system to perfection.
