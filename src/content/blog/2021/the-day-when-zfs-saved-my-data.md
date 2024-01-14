---
title: The day when ZFS saved my data
date: '2021-05-21T20:45:00+0100'
url: /blog/2021/05/the-day-when-zfs-saved-my-data/
---

Today my work day didn't turn out the way I expected. It started like a
normal day, I woke up around the regular time, did my morning routine, sat at
my desk and started my work-issued laptop.

It booted up just fine, I connected it to my Ultrawide display, started going
through Slack and Email and catch up on some news while drinking my morning
tea and waking up.

Then after around an hour of work things started to hang up, most notably
Firefox totally froze up. I could launch a new terminal but not start `htop`,
I had a `htop` session in a terminal already because it's part of what I
usually have running. So I went there to look.

In my `htop` I had ever increasing load increasing with more than `1.0` in
load per second but nothing actually using any resources for real. Something
was definitely bad, probably with disk access. I tried to run `ls`, and it
just locked up.

Then I rebooted my laptop, started it up, the EFI took ages to show up and to
pass through to `systemd-boot`, but it eventually did, so the disk wasn't
fully dead. Then I went on to boot my system and the ZFS pool wouldn't import
and it said something along the lines that recovery would be possible but
that I would lose data.

This was the point where it got to me how bad it was.

## Looking up how bad it was

So I took my personal laptop, set up a NixOS to create a NixOS live USB stick
since that supports ZFS. Booted it up. I could indeed import the ZFS pool. I
then scrubbed the pool to confirm how bad it was.

This was the output from `zpool status -v`:

```
[root@nixos:/home/nixos]# zpool status -v
  pool: zroot
 state: DEGRADED
status: One or more devices has experienced an error resulting in data
        corruption.  Applications may be affected.
action: Restore the file in question if possible. Otherwise restore the
        entire pool from backup.
   see: https://openzfs.github.io/openzfs-docs/msg/ZFS-8000-8A
  scan: scrub in progress since Fri May 21 07:20:10 2021
        131G scanned at 649M/s, 70.2G issued at 347M/s, 143G total
        180K repaired, 49.18% done, 00:03:33 to go
config:

        NAME                                                     STATE      READ WRITE CKSUM
        zroot                                                    DEGRADED      0     0     0
          nvme-LENSE30256GMSP34MEAT3TA_FBBS19071030004166-part1  DEGRADED    206     0    96  too many errors  (reparing)

errors: Permanent errors have been detected in the following files:

        zroot/nix:<0x0>
        zroot/home@zfs-auto-snap_frequent-2021-05-21-08h15:<0x0>
        zroot/home@zfs-auto-snap_frequent-2021-05-21-08h15:/etu/.mozilla/firefox/<redacted>
        zroot/home:<0x0>
        zroot/home:/etu/.mozilla/firefox/<redacted>
        zroot/home:/etu/.mozilla/firefox/<redacted>
        zroot/home:/etu/.mozilla/firefox/<redacted>
```

While doing this scrub I had my kernel spamming messages like this:

```
[ 358.895359] blk_update_request: critical medium error, dev nvme0n1, sector
              279163624 op 0x0:(READ) flags 0x0 phys_seg 11 prio class 0
```

## Starting to recover

So obviously some of my Firefox state was damaged, no big deal, but my
snapshot created at 08:00 this morning was intact it seemed. So I managed to
do a ZFS send to back this snapshot up to my file server at home.

```sh
zfs send zroot/home@zfs-auto-snap_frequent-2021-05-21-08h00 | pv |
    ssh my-user@my-home-server 'cat > backups/work/home-filesystem.zfs'
```

This took a while because it was 25G worth of data. Most of which is "backed
up" in terms of repositories on GitHub or in form of database dumps that I
can do again. Then I would lose all my shell history and some miscellaneous
files that were in neither of these places. I also didn't want to sort all of
these things out from scratch.

The transfer of this snapshot was successful.

## Setting up a work environment

As a temporary measure I've imported my work NixOS modules on my private
laptop, then I got all utilities and tools needed to do my job. Sure still
needed some passwords and SSH-keys, but passwords I could get from the
password manager and SSH-keys could be added. So no biggie there.

Then I imported the ZFS snapshot that I've managed to recover from the work
laptop onto a new ZFS filesystem in the ZFS pool on my private laptop and
changed my private laptops NixOS configuration to mount the work home folder
instead of the regular one.

A NixOS rebuild later and I was back in business except that I needed to
rebuild some docker containers and such.

## Takeaways from today

I need a real and proper backup strategy, I was damn aware that I didn't have
one and I was sure about that I wouldn't be as scared or sad if this sort of
thing would happen since "most things are in git anyways".

This has proved to me that I need to set this up as soon as possible.

I was lucky that I had ZFS telling me so clearly what was wrong, how it was
wrong, what I could recover, what I couldn't recover so when I did recover my
data I'm sure that I managed to recover every single bit of data that I cared
about backing up. If it wasn't for ZFS I'm not sure that I would have noticed
as early as I did and I'm not sure that I would have been able to save any of
the data.

Snapshots on the machine you use isn't a replacement for backups, but it's a
really good tool for creating backups based on.
