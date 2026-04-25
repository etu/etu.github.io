---
title: Detailed setup of screen sharing in Wayland (Sway)
date: '2021-02-19T23:00:00+0100'
url: /blog/2021/02/detailed-setup-of-screen-sharing-in-sway/
tags: [Sway, Wayland, Linux]
---

Getting screen sharing to work on Wayland seems to be surprisingly hard.
Maybe it is compared to X11 that doesn't require any additional setup at all.

To have working screen sharing on Sway you really need three components
installed and set up with correct environment variables.

These three components are:

- `pipewire` (I have version: 0.3.21)
- `xdg-desktop-portal` (I have version: 1.8.0)
- `xdg-desktop-portal-wlr` (I have version: 0.1.0)

These three components has to have systemd user services. You should be able
to see them in the list if you run `systemctl --user`, just look for the
different programs name ending in `.service`.

You can also check on each service individually by running:

```sh
systemctl --user status pipewire.service
systemctl --user status xdg-desktop-portal.service
systemctl --user status xdg-desktop-portal-wlr.service
```

## Required environment variables

- `XDG_SESSION_TYPE=wayland`
- `XDG_CURRENT_DESKTOP=sway`

How you set this may vary depending on your distribution, in NixOS I did set
these in a global way. But this, surprisingly to me wasn't enough to make
them apply all the way through to systemd user services.

So I had to add the following to command to run before I log into sway:

```sh
systemctl --user import-environment XDG_SESSION_TYPE XDG_CURRENT_DESKTOP
```

It may be fine to start it after sway is launched as well, it probably just
has to be executed before you attempt to do any screen sharing.

Don't worry if they don't run at this point. They should be started by socket
activation when you start sharing your screen.

### Update: A recent update to sway 1.6 in nixpkgs broke screen sharing

Reported issue here [nixpkgs#119445](https://github.com/NixOS/nixpkgs/issues/119445).

Currently screen sharing works if you have the following lines in your sway
config to import the right things to the right places:

```sh
exec systemctl --user import-environment XDG_SESSION_TYPE XDG_CURRENT_DESKTOP
exec dbus-update-activation-environment WAYLAND_DISPLAY
```

## Testing screen sharing

Testing screen sharing can easily be done with a patched
Firefox started with `MOZ_ENABLE_WAYLAND=1` set or with a Blink based browser
with the `pipewire` flag enabled in `about://flags`.

> NixOS has pulled in a patch for Firefox (older than 83)
> to support Pipewire. This should mean that it doesn't need patching if it's
> newer than 83. [Link to source](https://github.com/NixOS/nixpkgs/blob/f30c67cc99b56f3380fe417f361fe84492ee77de/pkgs/applications/networking/browsers/firefox/common.nix#L134-L140).

To actually test screen sharing I'd recommend using Mozilla's [gUM Test Page](https://mozilla.github.io/webrtc-landing/gum_test.html),
then just start your screen share on that page.

## What should happen?

Starting the screen share should trigger the socket activation for the user
services for `pipewire.service`, `xdg-desktop-portal.service` and
`xdg-desktop-portal-wlr.service`. In other words, these three services
*should* be started automatically when you start sharing your screen.

There's no real use to start them manually if they aren't running at this
point since they require the environment variables to work regardless if they
run or not.

## What if the services doesn't start?

Then it doesn't work. You can just stop the services that may have started,
then try to adjust your environment variables and try again.

You can check on each service with the commands above. If you want to stop
all or specific services you can run the following to do so:

```sh
systemctl --user stop pipewire.service
systemctl --user stop xdg-desktop-portal.service
systemctl --user stop xdg-desktop-portal-wlr.service
```
