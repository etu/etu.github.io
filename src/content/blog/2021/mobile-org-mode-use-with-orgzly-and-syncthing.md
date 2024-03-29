---
title: Mobile org-mode use with Orgzly and Syncthing
date: '2021-08-02T21:30:00+0100'
url: /blog/2021/08/mobile-org-mode-use-with-orgzly-and-syncthing/
tags: [Emacs, Org-mode, Orgzly, Syncthing]
---

I've been an Emacs user for 13+ years, during this time I've been using
[org-mode](https://orgmode.org/) on and off for different thing.

Some examples where I currently use org-mode:

- Deployment of this website
- Making of presentation slides
- Project read me files
- Notes files
- Time reporting

I've tried to use it for to do's but never really managed, partly because I
wanted to have a good interface for my to do's on my phone. Then I wanted
quick synchronization to my computers to be able to pick up the changes
there.

Most of my personal files is in a personal git repository which I sync around
to all the computers where I need them. I'd wish to have the security and
reliability of git when handling my to do lists just to know that they ever
get corrupted or lost.

## Enter Orgzly

I've known about [Orgzly](http://www.orgzly.com/) for quite some time. It's an Android app which is
available on both [Orgzly on F-Droid](https://f-droid.org/packages/com.orgzly/) and
[Orgzly on Play Store {{< fa fab google-play >}}](https://play.google.com/store/apps/details?id=com.orgzly). The thing
that's been stopping me to actually try Orgzly out is the lack of options
when it comes to synchronization. For example I would like to synchronize
using git. There's an open issue for this [git synchroniztion #24](https://github.com/orgzly/orgzly-android/issues/24), it's been
open since `2017-02-27 Mon`, so I'm not having high hopes to see it resolved
any day soon.

I've also spent some time thinking about this and came to the conclusion that
I probably don't want git as a synchronization mechanism for something as
volatile as to do lists and notes. But I still want it somewhere in the back
end of my system as a way to make sure what changes are actually stored and
backed up.

This is when I started to look into Orgzly's other synchronization options,
this is, as of writing in the current version of the app (1.8.5) the
available options:

- **Dropbox** -- I'm not a customer of Dropbox so this was a no-go to begin
  with.

- **WebDAV** -- As far as I know I don't have an easily available WebDAV server
  that I can use which makes it easy to get the files to my laptops and
  desktop systems where I can use them with Emacs without doing any fancy
  scripting to sync the files by hand.

- **Directory** -- This just syncs to a directory on the device, doesn't sound
  like much. But it's the option I went for.

## Enter Syncthing

[Syncthing](https://syncthing.net/) is a project I've heard a lot of good things about through the
years, both from people, but also in chat rooms, blogs and podcasts. So I've
decided to try it out.
n
From my limited testing it seems to sync P2P (at least while on the same
network). It seems fairly reliable in it's syncing and it picks up the
changes almost instantly. I'm impressed by it so far.

## Concusions

I've set up Syncthing to synchronize `~/org` for me to my phone to a folder
that I've named `org-files` in the home directory. Then I've configured
Orgzly to synchronize to this folder on disk. Now I have near instant
synchronization between my phone and my computer. So I can access and make
changes to my notes and to do list on either device. Then when I'm at my
computer and have "a batch of changes" that I want to make sure to have
saved, I can always commit them to git. Because this `~/org` directory is
part of a git repository, and has always been.
