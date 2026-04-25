---
title: Back from Hyprland to Sway
date: '2024-08-29T21:30:00+0200'
tags: [Hyprland, Sway, Wayland, NixOS, Linux, Cosmic]
---

After a brief experiment with
[Hyprland](../07/switching-to-hyprland.md), I'm back to using Sway. My
experiment lasted less than a month, as I hoped Hyprland's window
selector would resolve my window-sharing woes.

It turns out it wasn't, because the first week back at work I had the
need to share a slideshow in full screen. Then it doesn't matter if
you can select a window anymore. So my workarounds with Sway would
have worked in that use case while my Hyprland set up…  didn't.

## Detour via Cosmic

[System76 announced Cosmic](https://system76.com/cosmic) in an Alpha
version which seemed fun to experiment with. So I've pulled in the
[flake for Cosmic](https://github.com/lilyinstarlight/nixos-cosmic) to
try it out. It was fairly straightforward to set up, configure and
use. However it has some bugs (all known upstream) that I find hard to
accept for daily use. But it gave me some inspiration and ideas at
least for things I want to have in my desktop.

After experimenting with Cosmic, I decided to return to Sway, but not
without incorporating some of the ideas and inspirations I gained.

Even though I'm not using Cosmic, I remain very impressed with the
work that System76 has done in terms of establishing and building a
new desktop environment for the modern Linux desktop.

## The Ultrawide Monitor Challenge turned sideways?

I was listening to a Linux Podcast named [Linux
Matters](https://linuxmatters.sh/35/) where they mentioned a computer
monitor named [LG
DualUp](https://www.lg.com/uk/monitors/ergo-monitors/28mq780-b/) and
tempted as I was… I got two of them for myself as well. So instead of
an Ultrawide challenge I now have an Ultratall challenge which isn't
much different from wide when it comes to screen sharing. However, I
do have pre-existing workarounds for that.

So now I have 2 monitors that both have the aspect ratio of `16:18`
and the resolution of `2560x2880`. So I basically have 2 QHD panels
above each other, per monitor. It's a glorious set up with a lot of
height for code and terminals.

## Upgrades to my Sway session

### Replaced lightdm with greetd

I've for a long time used lightdm, but I've never actually managed to
log in through lightdm. Not sure why. However, that has very rarely
been a problem because I've have had it set to auto login anyway
which has worked fine.

So it's a bit of an upgrade to switch to a login manager that works
for me even though I haven't found any settings for auto login.

### Keyboard configuration

While on Cosmic I never figured out if I could use my custom xkb
configuration file to configure my keyboard layout as I used to on
Sway. So I found out how to configure it as I want it using xkb
options instead.

```text
input "type:keyboard" {
  xkb_layout us
  xkb_model pc105
  xkb_options compose:102,compose:sclk,ctrl:nocaps
  xkb_variant dvorak
}
```

The bit I was having a hard time to find was `compose:102` that maps
the "Less Then, Greater Then, Pipe" or LSGT button to Compose.

And with this I've also found the option `console.useXkbConfig` in
NixOS to pick up the console keymap from the `services.xserver.xkb`
options so now my Caps Lock actually behaves as Control… even outside
the graphical environment.

### Theme

I've started to unify applications around the
[Catppuccin](https://catppuccin.com/) theme, it may be a bit pastel
for me but it seems to have enough contrast. It's also nice and
consistent and it has a [Nix Flake](https://github.com/catppuccin/nix)
that helps a lot with the set up for different applications.

Now, the same theme is applied across the TTY, Plymouth (for unlocking
the disk), the greetd greeter, Sway, Waybar, and other applications.

### Running tray things

I've done fancy things such as making sure the following nice tray
programs is started and working:

- Network Manager Applet (home-manager:
  `services.network-manager-applet.enable`)
- Blueman Manager (home-manager: `services.blueman-applet.enable`)

### Fixing my swayidle

Before I had `swayidle` configured to black the screen but not
actually suspend the computer… That's also fixed!

### Setting up wpaperd

I've switched wall paper for like the first time in 4 years, so I've
found some nice space images that fits on my new monitors without
stretching and then it rotates between a set of a bunch of images on
random rotation every 30 minutes. It's very pretty!

### Music player control

I've started reading about the
[`mpris`](https://wiki.archlinux.org/title/MPRIS) protocol and
`playerctl`, this was super easy to set
up. `services.playerctld.enable` and `services.mpris-proxy.enable` in
home-manager made it possible to control media players on my Linux
desktop with Bluetooth devices.

I've also managed to add this using the `mpris` module to `waybar`
which was super easy.

## Conclusion

Yes I left Sway, for like 3 weeks, which set me on a journey for
change to land on a better and more fancy sway that does more of the
things that I didn't know that I wanted it to do.
