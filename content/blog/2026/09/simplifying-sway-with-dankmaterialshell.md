---
title: Simplifying my Sway setup with DankMaterialShell
date: '2026-09-08T23:00:00+0200'
tags: [NixOS, Sway, Wayland, Linux, DankMaterialShell]
---

Over the years my [Sway](https://swaywm.org/) setup had grown into a pile of
independently configured single-purpose tools: a bar, a launcher that also
doubled as an emoji picker and power menu, a notification daemon, a lock
screen plus idle daemon, a media-key/Bluetooth setup glued together with a
few standalone helpers, and a separate screenshot tool. Each one worked, but
each one was its own little island with its own config format and its own
opinions about how to talk to the others.

[DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell) (dms-shell)
is a [Quickshell](https://quickshell.org/)-based Material 3 desktop shell
that replaces basically all of the above with one daemon and one IPC
interface (`dms ipc call ...`). This post covers migrating to it on NixOS.

## The old setup

- **Bar**: a standalone bar
- **Launcher / emoji picker / power menu**: a standalone launcher, three separate modes
- **Notifications**: a standalone notification daemon
- **Lock / idle**: a standalone lock screen plus idle daemon
- **Media keys**: raw exec commands to the usual CLI tools
- **Bluetooth**: a standalone applet
- **Screenshots**: a standalone screenshot tool

## The new setup

All of the above, replaced by dms-shell, driven through `dms ipc call ...`
from sway's keybindings.

## Step 1 - Enable the shell

DankMaterialShell ships a home-manager module, so getting it running was
mostly a matter of importing that module and enabling it. No bespoke
integration work needed for the shell itself. The interesting part was
everything that came after: ripping out the old tools and rewiring sway to
talk to dms-shell instead.

The module also exposes a `settings` attribute that maps straight onto
dms-shell's own `settings.json` schema, so anything you'd otherwise click
through in its GUI settings panel — bar layout and widgets, clock format,
idle timeouts, and so on — can be written declaratively instead:

```nix
programs.dank-material-shell.settings = {
  clockFormat = "24h";
  showSeconds = true;
  barConfigs = [
    {
      id = "default";
      leftWidgets = [ "cpuUsage" "memUsage" "battery" ];
      centerWidgets = [ "workspaceSwitcher" ];
      rightWidgets = [ "clock" "notificationButton" "systemTray" ];
    }
  ];
};
```

That's also how the idle timeouts in step 3 and the plugins further down get
configured — no manual clicking required, and the whole thing rebuilds from
one file.

## Step 2 - Replace the bar, launcher, and lock screen

The old bar and notification daemon could be removed outright, and sway's
keybindings for the launcher and power menu got rewired to call into
dms-shell instead:

```nix
"${modifier}+e" = "exec dms ipc launcher open";
"${modifier}+Escape" = "exec dms ipc powermenu open";
"${modifier}+l" = "exec loginctl lock-session"; # caught by an idle-daemon lock event
```

Locking goes through `dms ipc lock lock`, triggered either directly or via
an idle daemon's suspend/lock events.

## Step 3 - Hand idle management over to dms-shell

dms-shell ships its own idle manager, so the timeout-based half of the old
idle daemon's job could go away entirely. Only event-based locking (on
suspend, on an explicit lock command) needs to stay external, since those
aren't idle-*timeout* based:

```nix
acLockTimeout = 300; # Lock after 5 minutes idle
acPostLockMonitorTimeout = 60; # Turn the screen off 1 minute after locking
acSuspendTimeout = 600;
```

`acPostLockMonitorTimeout` turns the monitor off some time *after* locking —
something the old idle-timeout list never gave me for free.

## Step 4 - Route screenshots, media keys, and Bluetooth through dms

Same pattern everywhere: replace a raw exec with a `dms ipc call`, so
everything stays in sync with dms-shell's own on-screen-display:

```nix
Print = "exec dms screenshot region";
XF86AudioMute = "exec dms ipc call audio mute";
XF86AudioLowerVolume = "exec dms ipc call audio decrement 10";
XF86MonBrightnessUp = "exec dms ipc call brightness increment 10 ''";
XF86AudioPlay = "exec dms ipc call mpris playPause";
```

The old media-player daemon and Bluetooth applet could both be dropped
outright — dms-shell talks to MPRIS players directly, and has its own
Bluetooth control-center panel built in.

## `dms ipc call` returns exit 0 even when it fails

I hooked up a small script that pushes data into dms-shell via `dms ipc
call`. The naive version checked the exit code — which is *always* 0, even
when the actual output is `Target not found.` (this happens for a genuinely
invalid IPC target, but also for a real one hit before dms-shell has
finished registering its IPC handlers on startup). The fix is to check the
actual text of the output and retry for a bit instead of trusting the exit
code.

## Impermanence wiped a settings marker every boot

I run an ephemeral root with [impermanence](https://github.com/nix-community/impermanence),
so anything dms-shell writes under its config directory that isn't
explicitly persisted gets wiped on every reboot. Most of its runtime markers
have a sane fallback if missing, but one — a changelog-seen marker — doesn't,
so a changelog dialog popped up fresh on every single boot until I persisted
that one file explicitly.

## One ordering cycle, two deadlocked units

A small helper service I run alongside dms-shell needs to start once dms's
own service is up. My first attempt hung it off the same systemd target
dms-shell itself starts from, with an explicit ordering dependency on top —
but dms-shell's service *also* has a relationship to that same target, so
this formed a dependency cycle and deadlocked both units. Hanging the helper
directly off dms-shell's service instead of the shared target gives a plain
parent-child edge with no path back through anything else.

## The plugin ecosystem

dms-shell has a small plugin system, and a few community plugins replaced
functionality I used to get from other standalone tools:

- **[dms-emoji-launcher](https://github.com/devnullvoid/dms-emoji-launcher)** —
  emoji/unicode search from the launcher.
- **[nix-package-runner](https://github.com/iahccc/NixPackageRunner)** —
  search and `nix run`/`nix shell` nixpkgs packages ad-hoc from the launcher.
- **[dms-quick-capture](https://github.com/hthienloc/dms-quick-capture)** —
  region-select screenshot annotation and screen recording, bound to `Print`.

Plugins install declaratively, with one non-obvious catch: a plugin with no
settings of its own isn't auto-detected as needing its enabled-state
managed, so its toggle otherwise depends on manually flipping a switch in
Settings → Plugins after every rebuild rather than being fully declarative.

## A window-rule gotcha

One plugin's editor window wouldn't float by default. The fix is a normal
sway floating-window rule, but the obvious one — matching on the window's
`app_id` — doesn't work, because *every* dms-shell window shares the same
`app_id`: the bar, the launcher, the lock screen, and this editor all report
the same app. Matching on the window title too scopes the rule to just the
one window I actually wanted:

```nix
floating.criteria = [
  {
    app_id = "com.danklinux.dms";
    title = "Quick Capture";
  }
];
```

I found the exact title by asking sway directly rather than guessing:

```sh
swaymsg -t get_tree
```

## Final thoughts

The net result is fewer moving parts: one daemon instead of six, one IPC
surface instead of five different config formats, and a small, purely
declarative plugin system for the handful of extras I actually wanted. It's
not perfectly polished everywhere yet — some of this is quite fresh — but
even mid-migration it was already a simpler system to reason about than what
it replaced.
