#!/bin/bash

disk_dev="${1:-/dev/vda}"
boot_suffix="${2:-1}"
btrfs_suffix="${3:-2}"
mnt_root="${4:-/mnt}"
btrfs_options='defaults,compress=zstd,noatime'

mount -o "$btrfs_options,subvol=@" "$disk_dev$btrfs_suffix" "$mnt_root"
mkdir -p "$mnt_root"/{boot,.snapshots,home,var/log,var/cache/pacman/pkg,var/lib/libvirt/images}

mount "$disk_dev$boot_suffix" "$mnt_root"/boot

mount -o "$btrfs_options,subvol=@.snapshots" "$disk_dev$btrfs_suffix" "$mnt_root"/.snapshots
mount -o "$btrfs_options,subvol=@home" "$disk_dev$btrfs_suffix" "$mnt_root"/home
mount -o "$btrfs_options,subvol=@log" "$disk_dev$btrfs_suffix" "$mnt_root"/var/log
mount -o "$btrfs_options,subvol=@pkg" "$disk_dev$btrfs_suffix" "$mnt_root"/var/cache/pacman/pkg
mount -o "$btrfs_options,subvol=@libvirt" "$disk_dev$btrfs_suffix" "$mnt_root"/var/lib/libvirt/images

chattr +C "$mnt_root"/var/lib/libvirt/images
