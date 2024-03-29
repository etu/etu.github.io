---
title: 'NixOS: Setting up Push To Talk in Mumble on Sway'
date: '2021-06-26T22:40:00+0100'
url: /blog/2021/06/setting-up-push-to-talk-in-mumble-on-sway/
tags: [NixOS, Linux, Mumble, Sway, Wayland]
---

Switching to Wayland has it's side-effects, one of which is the improved
security from X11 where applications can't just randomly spy on each other at
any point.

This is both good news and bad news.

The good news:

- Applications can't just randomly spy on each other.

The bad news:

- Things like global hot-keys in for example Mumble won't work.

Back from complaining to actually solving the problem though.

## Mumble does have a patch for a future release

So there's the issue about [Push to talk does not work in Wayland](https://github.com/mumble-voip/mumble/issues/3243), this has
been followed up by a patch [Add DBus calls to de/-activate push to talk](https://github.com/mumble-voip/mumble/pull/3675). This
patch will land in the 1.4.0 release though while current stable is 1.3.4.

A thing with mumble is that they aren't quick at releasing new versions, so
sitting around and waiting for a new release might… take a while.

## Sway has patches for this

Since version 1.5 Sway has a patch to be able to bind keys that doesn't
repeat it's action, but it still works to bind them to trigger a release
event which sounds a lot like a push to talk buttons function to me.

Here's the patch that was applied to Sway: [add --no-repeat option for bindings](https://github.com/swaywm/sway/pull/5132).

## Actually making use of these things in NixOS

I started by patching mumble to support the dbus calls:

```nix
{
  # …

  environment.systemPackages = [
    # Add a patch to mumble to be able to use dbus for push to talk
    (pkgs.mumble.overrideAttrs (oa: {
      # Here we keep the patches from the package while we import the
      # patch from the pull request that did add the dbus features needed.
      patches = oa.patches ++ [
        # Download the patch from pull request 3675.
        (pkgs.fetchpatch {
          url = "https://github.com/mumble-voip/mumble/pull/3675.patch";
          sha256 = "1zmqb8gl2cp0mcw85x9wn5rjw2mih7d2x96jxxqabjcx1kvgyhh3";
        })
      ];
    }))
  ];

   # …
}
```

Then I've added the following lines to my sway configuration:

```plain
# Add PTT button for mumble:
bindsym --no-repeat           Super_L exec gdbus call -e -d net.sourceforge.mumble.mumble -o / -m net.sourceforge.mumble.Mumble.startTalking
bindsym --no-repeat --release Super_L exec gdbus call -e -d net.sourceforge.mumble.mumble -o / -m net.sourceforge.mumble.Mumble.stopTalking
```

(Note, `gdbus` comes from the package `glib`)

Now you can launch up Mumble, you don't have to actually bind any keybinding
for this to work since it's not actually a key bind but a dbus event. This
also means that you can't test this while not connected to a server. When
connected to a server and in a room where you have permissions to speak it
works perfectly fine like a Push To Talk button.
