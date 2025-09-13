---
title: Migrating from ZFS mirror to RAIDZ2
date: '2025-09-13T20:00:00+0200'
url: /blog/2025/09/migrating-zfs-mirror-to-raidz2/
tags: [ZFS, Linux]
---

For a long time I've been running my storage on a 2-disk ZFS
mirror. It's been stable, safe, and easy to manage. However, at some
point, 2 disks just aren't enough, and I wanted to upgrade to RAIDZ2
so that I could survive up to two simultaneous disk failures.

I could have added another mirror, which would have been simple, and
this setup would allow two drives to fail, but not any two drives. I
wanted the extra safety of being able to lose **any two drives**.

## The problem?

I didn't have four new disks lying around. Buying four 18TB drives at
once would have been expensive. I already had two 18TB drives I wanted
to keep using and a third one at home, so getting just one additional
18TB drive would be the cheapest way to expand. I also wanted to avoid
ever being in a state with **no redundancy** during the migration.

This post will show how I migrated from a 2-disk ZFS mirror to a
4-disk RAIDZ2, step by step, while never being unprotected.

### Initial setup

Here's where we started:
- `zstorage` - an existing pool made up of two mirrored drives:
  - `mirror-0`
    - `diskA`
    - `diskB`

### Target setup

My goal was to end up with this:
- `zstorage` - a new pool, now made up of four drives in RAIDZ2:
  - `raidz2-0`
    - `diskA`
    - `diskB`
    - `diskC`
    - `diskD`

While keeping all data safe throughout the process.

## Step 1 - Add two new drives and a temporary placeholder

RAIDZ2 requires at least three devices to exist, but I only had two
new drives. To make this work, I created a **loopback file** to
temporarily act as a third *disk*.

This allowed me to create a degraded RAIDZ2 vdev with the two new
drives plus the loop device.

```sh
# Create a sparse file, about the same size as your new drives
truncate -s 18T /mnt/placeholder.img

# Attach it as a loop device
losetup /dev/loop0 /mnt/placeholder.img

# Identify your two new drives
DISKC=/dev/disk/by-id/ata-ST18000NT001-…
DISKD=/dev/disk/by-id/ata-ST18000NE000-…

# Create the new pool
zpool create -o ashift=12 \
  -O mountpoint=none \
  -O atime=off \
  -O acltype=posixacl \
  -O xattr=sa \
  -O compression=lz4 \
  -O encryption=aes-256-gcm -O keyformat=passphrase \
  zstorage-ng raidz2 $DISKC $DISKD /dev/loop0
```

At this point, `zstorage-ng` was fully functional and healthy, while the
original `zstorage` mirror remained intact as a separate pool.

Then I removed the sparse file to prevent it from taking up space:
```sh
# Remove the sparse file
losetup -d /dev/loop0
rm /mnt/placeholder.img
```

The pool would now be degraded but still fully operational.

## Step 2 - Copy data to the new pool

Next, I copied all datasets from the old mirror to the new pool using
syncoid.

Make an incremental send/receive from the old pool to the new pool:
```sh
syncoid --recursive zstorage zstorage-ng
```

> 💡 Tip: Run this multiple times — the first run copies all data,
> subsequent runs are much faster and just catch up incremental
> changes.

This process may take a couple of days, depending on the amount of
data.

When the first run was done, I ran it again to catch any changes that
occurred after the initial copy.

Once the sync was complete, I stopped all services using the old pool,
unmounted the old pool, ran the sync one last time, mounted the new
pool in its place, and verified that everything was working correctly.

At this point, the new pool was fully functional but degraded and
still one disk short.

Parity-wise, I still had the old mirror intact with one-device
redundancy and the new pool with one-device redundancy - similar to
having a mirror, but technically degraded since RAIDZ2 expects
two-device redundancy.

## Step 3 - Remove a device from the old pool

This step triggers a resilvering operation on the new pool to repair
it from the missing loop device.

```sh
# Detach one of the disks from the mirror
zpool detach zstorage /dev/disk/by-id/ata-OLDMIRROR-DISK-B

# Replace the missing loop device in the raidz2
zpool replace zstorage-ng /dev/loop0 /dev/disk/by-id/ata-OLDMIRROR-DISK-B
```

This will also take time, depending on the amount of data.

During this stage, I still had the old pool with one remaining disk
holding a full copy of my data. When the resilver completed, the new
pool became fully functional and healthy, with full two-disk
redundancy.

At this point, I had no extra storage space yet, just a different,
more resilient layout.

## Step 4 - Destroy the old pool and expand

Finally, I destroyed the old pool and used the last device in the new
pool by triggering a RAIDZ expansion.

```sh
# Destroy the old pool
zpool destroy zstorage

# Attach the last disk to the new pool
zpool attach zstorage-ng /dev/disk/by-id/ata-OLDMIRROR-DISK-A
```

This took a long time as well - first to recompute all the parity
during the expansion process, and then to scrub the finished result.

A zpool status looked like this during the final scrub:

```text
  pool: zstorage-ng
 state: ONLINE
  scan: scrub repaired 0B in 22:09:24 with 0 errors on Mon Sep  8 14:20:59 2025
expand: expanded raidz2-0 copied 46.0T in 2 days 02:23:56, on Sun Sep  7 16:11:35 2025
config:

	NAME                                  STATE     READ WRITE CKSUM
	zstorage                              ONLINE       0     0     0
	  raidz2-0                            ONLINE       0     0     0
	    ata-ST18000NT001-3LU101_WR50M2VL  ONLINE       0     0     0
	    ata-ST18000NE000-2YY101_ZR585MAG  ONLINE       0     0     0
	    ata-ST18000NE000-2YY101_ZR54LVT1  ONLINE       0     0     0
	    ata-ST18000NE000-2YY101_ZR54FG62  ONLINE       0     0     0

errors: No known data errors
```

## Step 5 - Final cleanup

Finally, I renamed my new pool to match the old name, so that all
mount points and scripts would continue to work without changes.

```sh
# Export the new pool
zpool export zstorage-ng

# Import it with the old name
zpool import zstorage-ng zstorage
```

## Final thoughts

This migration took careful planning, but it allowed me to grow from a
2-disk mirror to a 4-disk RAIDZ2 without ever being unprotected.

Now I have:
- 36T usable space
- Tolerance for two simultaneous disk failures

ZFS is an incredibly flexible filesystem, and with a bit of
creativity, you can do major migrations like this without risking your
data.

As long as you use ZFS send/receive for copying data, you can always
be sure that you have a consistent copy of your data on the new pool
before switching over.
