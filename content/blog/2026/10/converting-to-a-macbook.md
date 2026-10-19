---
title: How I ended up on a MacBook (and actually liked it)
date: '2026-10-19T22:00:00+0200'
tags: [macOS, Nix, nix-darwin, home-manager, AeroSpace]
---

For about 10 years I've worked at the same company, and for about 9 of
those years I've been running [NixOS](https://nixos.org/) on my work
machine with a setup that I've built and tuned exactly the way I want
it.

Then corporate security decided that all devices needed to be
managed. That's a perfectly reasonable requirement from their side,
but it's not something that works with a custom NixOS setup. So I got
handed a MacBook Pro.

I was absolutely certain that I would hate it.

## Bringing Nix along

Instead of giving up on my setup, I started exploring what Nix can do
on macOS. With [nix-darwin](https://github.com/nix-darwin/nix-darwin)
for the system level and
[home-manager](https://github.com/nix-community/home-manager) for my
user environment, it turns out that a surprisingly large part of how
I like to work carries over. It's actually pretty great.

Getting started was quick. With Nix installed, all I had to do was move
away the `nix.conf` that nix-darwin wants to manage, and then do the
first activation:

```sh
sudo mv /etc/nix/nix.conf /etc/nix/nix.conf.before-nix-darwin
sudo nix --extra-experimental-features 'nix-command flakes' \
  run nix-darwin -- switch --flake .#macbook-air-elis
```

After that it's the same workflow as on NixOS: change the config,
commit, activate. The whole setup is about 50 commits over four days,
and a lot of them are just moving things I already had into modules
that both NixOS and nix-darwin can import. My configs for Emacs, fish,
git and Ghostty are now shared between the platforms, and CI builds the
Darwin hosts on macOS runners next to the NixOS ones.

I'm pretty sure macOS would be unusable for me without a proper package
manager like Nix. At the same time, it's kind of nice that I don't have
to manage *everything* with it. Firefox, for example, I just installed
as a normal application and let it update itself.

### Making macOS behave

A surprising amount of what annoyed me about macOS turned out to be
settings that nix-darwin exposes as options. This is most of my
`system` module:

```nix
{
  # Use dark mode.
  system.defaults.NSGlobalDomain.AppleInterfaceStyle = "Dark";

  # Hide the Dock, and don't show recently used apps in it.
  system.defaults.dock.autohide = true;
  system.defaults.dock.show-recents = false;

  # Show battery percentage and Bluetooth in the menu bar.
  system.defaults.controlcenter.BatteryShowPercentage = true;
  system.defaults.controlcenter.Bluetooth = true;

  # Faster key repeat (in units of 15 ms).
  system.defaults.NSGlobalDomain.InitialKeyRepeat = 25;
  system.defaults.NSGlobalDomain.KeyRepeat = 2;

  # Caps Lock is Control. Obviously.
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToControl = true;

  # Use Touch ID for sudo, also inside tmux.
  security.pam.services.sudo_local.touchIdAuth = true;
  security.pam.services.sudo_local.reattach = true;
}
```

Touch ID for `sudo` is one of those things I didn't know I wanted. The
`reattach` part is needed for it to work inside tmux, since processes
started by the tmux server otherwise aren't connected to the login
session.

Another nice surprise is SSH. macOS already runs an `ssh-agent` per
login session, and Apple's `ssh` can read key passphrases from the
Keychain. So instead of setting up my own agent, I just told
home-manager to use it:

```nix
programs.ssh.settings."*" = {
  AddKeysToAgent = "yes";

  # UseKeychain only exists in Apple's ssh, don't let other ssh builds
  # fail on it.
  IgnoreUnknown = "UseKeychain";
  UseKeychain = "yes";
};
```

## The bad parts: window manager and terminal

The two most terrible things about macOS out of the box are the window
management and the terminal emulator.

The terminal emulator is the easy one, just replace it. I already use
[Ghostty](https://ghostty.org/) on NixOS, so I shared that home-manager
module with nix-darwin and only needed a couple of macOS-specific
tweaks on top:

```nix
programs.ghostty = {
  # The official macOS build (the source build is Linux-only).
  package = pkgs.ghostty-bin;

  settings = {
    # Always start fish, regardless of the account's login shell.
    command = lib.getExe config.programs.fish.package;

    # Quit when the last window is closed, like on Linux.
    quit-after-last-window-closed = true;
  };
};
```

The window manager is harder since you can't really replace it, but
[AeroSpace](https://github.com/nikitabobko/AeroSpace) gets me close
enough to a tiling workflow that it's actually pretty great. It's an
i3-like tiling window manager for macOS, and nix-darwin has a module
for it.

I configured it to mirror my [Sway](https://swaywm.org/) keybindings
as closely as possible. The main difference is using Alt as the
modifier instead of Super, since Cmd collides with most macOS
shortcuts. AeroSpace even has a Dvorak key-mapping preset, so the
bindings end up on the same physical keys as on Sway:

```nix
services.aerospace.settings = {
  # Bind keys by Dvorak letters, like on sway.
  key-mapping.preset = "dvorak";

  # Workspaces I-X always exist, like sway's numbered workspaces.
  persistent-workspaces = [ "Ⅰ" "Ⅱ" "Ⅲ" "Ⅳ" "Ⅴ" "Ⅵ" "Ⅶ" "Ⅷ" "Ⅸ" "Ⅹ" ];

  mode.main.binding = {
    "alt-enter" = "exec-and-forget open -na Ghostty";
    "alt-shift-quote" = "close";

    # Emacs-style directions to move focus around.
    "alt-b" = "focus --wrap-around left";
    "alt-f" = "focus --wrap-around right";
    "alt-p" = "focus --wrap-around up";
    "alt-n" = "focus --wrap-around down";

    # Closest thing to sway's split h/v.
    "alt-h" = "join-with right";
    "alt-v" = "join-with down";

    # ...and so on for moving windows, layouts and workspaces.
  };
};
```

It wasn't all smooth sailing though. A couple of things I ran into:

- **Opening a new terminal.** On Sway I just exec the terminal. On
  macOS the obvious way would be to ask Ghostty for a new window over
  AppleScript, but AeroSpace doesn't declare that it sends Apple Events,
  so macOS silently refuses. So instead every Alt+Return starts a new
  Ghostty instance with `open -na Ghostty`, which is also why
  `quit-after-last-window-closed` is needed. Otherwise every closed
  terminal leaves an instance running in the Dock.
- **Emacs floating above everything.** Emacs started from Spotlight
  refused to tile and floated on top of all workspaces. It turned out
  that the Nix-wrapped `Emacs.app` execs a wrapper that in turn execs
  the real Emacs binary from *another* app bundle, and a process
  launched as one bundle but running from another isn't picked up by
  AeroSpace. The fix was to make `Emacs.app` start the wrapped
  `bin/emacs` as a separate process instead, just like starting it
  from a terminal.

## The good parts: it's solid

With those two things sorted, what's left is a system that feels solid
and snappy. The hardware is great too:

- **Build quality** is excellent.
- **Performance** is great.
- **It doesn't run hot.**
- **Battery life** lasts for days.

## Getting a private one as well

After just a few days I decided to get a private MacBook as well, so I
have something to play with in the evenings and not only the work one.

For the private one I went with a MacBook Air rather than a Pro. It's
slightly cheaper, it weighs less, and I don't need the Pro performance
for what I do on my own time. I did, however, get it with 24 GB of RAM
so that I have room to play around with development and running some
AI models locally.

Having a private one also makes the setup easier to structure. I can
keep a Darwin configuration in my public GitHub repository, and then
have my work repository inherit from that and bolt on the
work-specific things that shouldn't be in a public repository.

My [public config](https://github.com/etu/nixconfig) exports all the
Darwin modules, so the work flake can import them as
`darwinModules.default` and only add what's specific to work. Some
defaults are set with `lib.mkDefault` so the work flake can override
them. One example is recording which git revision the system was built
from:

```nix
# mkDefault so flakes that import these modules, like the work
# MacBook's, can record their own revision instead.
system.configurationRevision = lib.mkDefault (flake.rev or flake.dirtyRev or null);
```

## The one strange problem: my Apple account

There is one strange problem I've run into, and it has nothing to do
with Nix.

Quite some time ago I created an Apple account using my private email
address. When I tried to sign into it on my new MacBook, I got asked
to enter a phone number. So I entered my phone number, and was told
that it *can't verify using my phone number at this time*.

Waiting doesn't help. Waiting more doesn't help. Password recovery
doesn't help. I have no clue what's going on.

So I called Apple support, and that turned out to be a surprisingly
pleasant experience. Everyone I talked to was super nice.

The first person didn't know what was wrong. He tried adding my phone
number as a trusted number, and all sorts of other things, before
escalating it to a senior advisor. They didn't know either, so I was
asked to take some screenshots, try again later, take more screenshots
and send them all in by email.

This senior advisor then took personal responsibility for my case. He
scheduled a follow-up call with me a couple of days later, and called
me on the exact minute it was scheduled. He had looked through my
screenshots, asked some follow-up questions, and then escalated the
issue again, this time to the actual engineers. He'll get back to me
once it's resolved.

I usually have very low expectations of support, but so far Apple
support has been really impressive.

<!-- TODO: Update with how it was resolved, if/when it is. -->

## Conclusion

I enjoy it much more than I ever expected to. It's actually *fun* to
use, more so than my ThinkPad, which is a weird thing for me to say.
