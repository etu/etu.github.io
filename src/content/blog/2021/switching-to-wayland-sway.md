---
title: Switching to Wayland (Sway)
date: '2021-02-17T22:00:00+0100'
url: /blog/2021/02/switching-to-wayland-sway/
tags: [NixOS, Nix, Linux, Sway, Wayland, X11]
---

Like every other desktop Linux user for the past many years I've used X11. I
was on [i3wm](https://i3wm.org/) for quite some time until I was introduced to
[Emacs X11 Window Manager](https://github.com/ch11ng/exwm) which I used
exclusively for about 18 months, I've even held a [talk](/talks/) about it.
But at some point it got too annoying, for example in multi monitor use cases.

At this point my first step was to go back to set up i3wm again. With that
set up I wanted to give [SwayWM](https://swaywm.org/) another attempt, it was
years ago I've checked it out before. I think my previous experience was when the
project was new. At that point (if I remember correctly), not even the window
decorations looked like the ones in i3wm.

## Key map

As a US Dvorak typist that sometimes types Swedish, I have opinions about key
maps. Since I used xmodmap before to customize my key map to make it work for
me, I needed to replicate this for Sway.

It took some tinkering, but I've ended up with the following custom key map:

```config
// This file defines my own custom keymap. More information about
// which parts that gets included are available in the different
// subfolders in: /usr/share/X11/xkb/
xkb_keymap {
  xkb_keycodes { include "evdev+aliases(qwerty)" };
  xkb_types    { include "default" };
  xkb_compat   { include "complete" };
  xkb_symbols  {
    include "pc+us(dvorak)+inet(evdev)+ctrl(nocaps)+eurosign(e)+kpdl(dot)"

    // Less than/Greater than/Pipe key on Swedish keyboards becomes Compose
    replace key <LSGT> { [ Multi_key ] };

    // Scroll Lock becomes Compose
    replace key <SCLK> { [ Multi_key ] };
  };
  xkb_geometry { include "pc(pc105)" };
};
```

I put that as a file somewhere, and then I have the following in my sway
configuration:

```config
input "type:keyboard" {
  xkb_file /path/to/xkb/file
}
```

## Browsers

I use Firefox as my main browser, it works mostly fine native on Wayland. It
happens now and then that I encounter things that are less than perfect
(especially at work) where I'll give in and run some Blink based browser in
Xwayland.

Firefox just needs some convincing with `MOZ_ENABLE_WAYLAND=1` in the
environment set.

## Editor

As a long time Emacs user I'll just keep using Emacs. To begin with I did so
in Xwayland - but it had some issues at some point which pushed me to try out
the pgtk branch from a user on GitHub. It's been great since I started using
it and that branch is now accepted as a feature branch on Savannah, so now I
hope it's mainlined before Emacs 28.

## Screen sharing

It works! `*`

See [Detailed setup of screen sharing in Wayland (Sway)](/blog/2021/02/detailed-setup-of-screen-sharing-in-sway/) for more detailed
notes on getting this to work.

`*` It works to do full screen sharing using `pipewire`,
`xdg-desktop-portals` and `xdg-desktop-portals-wlr`. This requires the right
environment variables - then it works fine, with the limitation that you can
only share the entire screen - but not single windows.

This limitation is extra annoying when using an [ultra wide monitor](/blog/2021/02/ultra-wide-monitor/) since nobody else can actually see this stream
properly. One hacky workaround I have for this is to run a browser in
Xwayland which makes it possible to share other Xwayland applications. Then
to have an Emacs instance running in Xwayland, then I can share that Emacs
window. Since Emacs is so flexible I can share most things through that.

To get Firefox screen share to work, NixOS have pulled in some patches from
Fedora, then you just run it in Wayland mode and it's fine.

Chrome has a flag to enable pipewire support.

I know there's a flag that can be provided to `xdg-desktop-portals-wlr` to
specify which screen to share. I'm not sure how to manage that easily in a
multi screen environment.

## Miscellaneous applications

- Screenshots: `grim -g $(slurp) - | swappy -f -`
- Back light: `acpiilight`
- Lock screen: `swaylock` & `swayidle`
- Notifications: `mako`
- PDF Viewer: `emacs` with `pdf-tools`
- Launcher: `rofi` in Xwayland (I should look into `wofi` some day)
- Image viewer: `emacs` or `feh` in Xwayland
- Graphical display settings: `wdisplays` is great!
- Command line display settings: `wlr-randr`

## Conclusions

My road to Wayland with Sway have for sure have had a couple of road bumps.
The only real bump that has been a software limitation has been how screen
sharing works, but I've found workarounds for these situations that works for
me.

The overall experience have been a much nicer Linux desktop, there's no
tearing, everything just gives the perception and feels faster and smoother.
