---
title: Switching from Sway to Hyprland
date: '2024-07-23T16:40:00+0200'
tags: [Hyprland, Sway, Wayland, NixOS, Linux]
---

## Introduction

After four years with Sway, I've decided to transition to Hyprland. My
journey from EXWM to Sway began about four years ago, and I documented
the experience in
[this post](/blog/2021/02/switching-to-wayland-sway/) three years ago.
While Sway has served me well, it has its limitations that I've used
hacks and workarounds to circumvent.

## The Limitations of Sway

One major drawback of Sway is its
[screen sharing](/blog/2021/02/detailed-setup-of-screen-sharing-in-sway/)
capabilities. Although I managed to get screen sharing somewhat
functional, it only allows sharing the full screen.

### The Ultrawide Monitor Challenge

This limitation is particularly problematic for someone like me, who
uses an [ultrawide monitor](/blog/2021/02/ultra-wide-monitor/) with a
high resolution and odd aspect ratio. Sharing such a large screen
makes it difficult for others to view the content effectively. For
instance, when conducting presentations or collaborating online, the
full-screen sharing of an ultrawide monitor can be impractical and
cumbersome.

## Workarounds and Hacks

To circumvent this issue, I've tried various hacks in Sway. One of
them involved running nested Sway sessions, reloading specific
environment variables, and launching a browser inside the nested
session to enable full-screen sharing. While this method works, it's
far from ideal and introduces unnecessary complexity into my workflow.

### The Ongoing Issue

There's an open issue
[`emersion/xdg-desktop-portal-wlr#107`](https://github.com/emersion/xdg-desktop-portal-wlr/issues/107)
aiming to address the inability to share specific windows in
Sway. This issue, active since 2021, offers numerous workarounds but
lacks a definitive solution. The lack of progress on this front
several years later has pushed me to look elsewhere.

## Discovering Hyprland

I've been keeping an eye on Hyprland for a while, and it seems to have
robust support for sharing specific windows, regions, or the full
screen. This feature works seamlessly, making it a significant upgrade
over Sway. Hyprland's approach to window management is similar but
also different from Sway, requiring some configuration and getting
used to.

## Setting Up Hyprland

### Configuration and Customization

One of the major projects that made the transition to Hyprland easier
is the plugin [`hy3`](https://github.com/outfoxxed/hy3), which makes
Hyprland function more like Sway. For instance, Hyprland doesn't
support tabbed layouts, something that hy3 adds, making the transition
smoother for Sway users.

### Improved Workflow

With the ability to share specific windows or regions, I can now
conduct presentations and collaborate online without the previous
hassles. This improvement alone has made the transition worthwhile.

## Conclusion

If you're considering a switch or facing similar challenges with Sway,
I highly recommend giving Hyprland a try. The community support and
the robust feature set make it a compelling choice for any Linux user
looking for a more flexible and powerful window manager.

I may go in depth in further posts about different components (such
as, lock screens, idle management, wallpaper handling) of my Hyprland
setup.
