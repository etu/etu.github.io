---
title: Encrypted ZFS mirror with mirrored boot on NixOS
date: '2019-08-04T10:20:00+0200'
url: /blog/2019/08/encrypted-zfs-mirror-with-mirrored-boot-on-nixos/
tags: [NixOS, Linux, ZFS]
---

So for a long time I have wanted to replace my file server, because it's an
old HP Microserver that is really slow. And at the same time I have had this
beast of a desktop tower PC that I haven't used with a Xeon and 32GiB ECC
memory that has just been turned off due to noise. The obvious solution is to
re-purpose that install and move it to a location where noise doesn't matter,
e.g. the closet (a.k.a the server room) where the file server lives.

## My requirements on this setup

To do this move I had a certain list of requirements:

1. Mirrored boot disk
1. Mirrored ESP
1. Encrypted ZFS
1. NixOS

With these requirements, the goal is that whichever disk should be able to
die and the system should still just boot. Without any issues. Sure the raid
or system like a raid will complain. But the system should still come up even
if one disk die.

## Step 1 - Partitioning

I followed these steps of partitioning grabbed from the [NixOS on ZFS](https://wiki.nixos.org/wiki/ZFS#Simple_NixOS_ZFS_installation) page but
modified my steps.

```sh
# Defining some helper variables (these will be used in later code
# blocks as well, so make sure to use the same terminal session or
# redefine them later)
DISK1=/dev/disk/by-id/ata-VENDOR-ID-OF-THE-FIRST-DRIVE
DISK2=/dev/disk/by-id/ata-VENDOR-ID-OF-THE-SECOND-DRIVE

# Creating partitions
# This creates the ESP / Boot partition at the beginning of the
# drive but numbered as the third partition:
sgdisk -n3:1M:+512M -t3:EF00 $DISK1

# This create the storage partition numbered as the
# first partition:
sgdisk -n1:0:0 -t1:BF01 $DISK1

# Clone the partitions to the second drive:
sfdisk --dump $DISK1 | sfdisk $DISK2
```

## Step 2 - Creating the pool

Creating a ZFS pool can be intimidating for the first times you do it, there
is a lot of options and flags. And you have both properties/features that use
the flag `-o` and then you have file system properties that use `-O`.

To me this is still confusing, but I managed to get it together after some
fiddling around.

You can read more about these flags on these locations:

- https://wiki.nixos.org/wiki/ZFS
- https://wiki.archlinux.org/index.php/ZFS#Advanced_Format_disks

And many more places around the web…

```sh
# Some flags to consider
#
# Disable ZFS automatic mounting:
#   -O mountpoint=none
#
# Disable writing access time:
#   -O atime=off
#
# Use 4K sectors on the drive, otherwise you can get really
# bad performance:
#   -o ashift=12
#
# This is more or less required for certain things to
# not break:
#   -O acltype=posixacl
#
# To improve performance of certain extended attributes:
#   -O xattr=sa
#
# To enable file system compression:
#   -O compression=lz4
#
# To enable encryption:
#   -O encryption=aes-256-gcm -O keyformat=passphrase

# Then we create the pool which is mirrored over both drives and
# encrypted with ZFS native encryption (if you added those flags):
zpool create <FLAGS> zroot mirror $DISK1-part1 $DISK2-part1
```

## Step 3 - Creating the file systems

### Step 3.1 - ZFS file systems

Here you can create which ever you want, this is not exactly how my set up
mine due to my usage of tmpfs as root, but that's a topic for another post.

```sh
zfs create -o mountpoint=legacy zroot/root      # For /
zfs create -o mountpoint=legacy zroot/root/home # For /home
zfs create -o mountpoint=legacy zroot/root/nix  # For /nix
```

### Step 3.2 - The ESP partitions

This will seem really obvious at this point, but what's not obvious is how to
keep them in sync. In the past (with MBR) I would make an mdraid level 1
across the drives and have that as /boot and the system would boot fine from
any drive. It's not that simple with UEFI.

Although, this guy have a good write up on how to achieve this same thing on
Debian/Ubuntu. And that probably works on other distributions as well.
https://outflux.net/blog/archives/2018/04/19/uefi-booting-and-raid1/

```sh
mkfs.vfat $DISK1-part3
mkfs.vfat $DISK2-part3
```

## Step 4 - Mounting the file systems

This takes a bit of work to do, many drives many steps, etc. If you have
rebooted your live media because you need to rescue or try again in some way
with the configuration you should start with importing the pool and loading
the key to the encrypted disk.

This isn't needed if you're still up and running on the same session as where
you created your pool.

```sh
zpool import zroot
zfs load-key zroot
```

To mount the file systems you probably want to do something like this:

```sh
mount -t zfs zroot/root /mnt

# Create directories to mount file systems on
mkdir /mnt/{nix,home,boot,boot-fallback}

# Mount the rest of the ZFS file systems
mount -t zfs zroot/root/nix /mnt/nix
mount -t zfs zroot/root/home /mnt/home

# Mount both of the ESP's
mount $DISK1-part3 /mnt/boot
mount $DISK2-part3 /mnt/boot-fallback
```

## Step 5 - Configuration of the boot loader

Here we have the magic of the NixOS module systems kicking in that will make
this entire setup awesome and easy to manage.

Just start by the regular `nixos-generate-config --root /mnt`.

Then you want to use grub as a boot loader and not systemd-boot.

I have the following configured to make my system support ZFS:

```nix
{
  boot.supportedFilesystems = [ "zfs" ];
  networking.hostId = "<8 random numbers>";
}
```

Then I have the following to boot with grub and keep my two grubs in sync:

```nix
{
  # You can probably use his one on true, but my UEFI is buggy.
  boot.loader.efi.canTouchEfiVariables = false;

  # This is the regular setup for grub on UEFI which manages /boot
  # automatically.
  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.device = "nodev";

  # This will mirror all UEFI files, kernels, grub menus and things
  # needed to boot to the other drive.
  boot.loader.grub.mirroredBoots = [
    { devices = [ "/dev/disk/by-uuid/<FS-ID>" ];
      path = "/boot-fallback"; }
  ];
}
```

## Conclusion

NixOS makes it really easy to set up encrypted ZFS that is reliable when it
comes to updates and usage.

And with the module system NixOS makes it easy to keep the two ESP partitions
in sync.

I have tested the entire process to make sure it works on my hardware by:

1. Shut it down
1. Unplug one drive
1. Boot it up all the way into the system and watched ZFS be a bit grumpy
   about some missing disk (oh what a surprise!)
1. Shut it down
1. Plug in he first drive and unplug the other one
1. Repeat step 3 again
1. Shut it down
1. Boot with both disks and tell ZFS that I'm sure that there's no issue with
   my hardware and that I don't want to replace my drives.

So now that computer have moved to the closet (a.k.a. the server room) and
I've configured it so I can unlock the drive over SSH on boot following:
https://wiki.nixos.org/wiki/ZFS#Unlock_encrypted_zfs_via_ssh_on_boot
