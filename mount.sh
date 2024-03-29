#!/bin/bash

disk_dev="${1:-/dev/vda}"
boot_suffix="${2:-1}"
btrfs_suffix="${3:-2}"
mnt_root="${4:-/mnt}"
swap_size="${5:-"$(( ($(cat /sys/power/image_size) + 1000000000) / 1000000000 ))"}"
btrfs_options='defaults,discard=async,compress-force=zstd,noatime'

mount -o "$btrfs_options,subvol=@" "$disk_dev$btrfs_suffix" "$mnt_root"
mkdir -p "$mnt_root"/{boot,.snapshots,home,var/log,var/cache/pacman/pkg,var/lib/libvirt/images,swap}

mount "$disk_dev$boot_suffix" "$mnt_root"/boot

mount -o "$btrfs_options,subvol=@snapshots" "$disk_dev$btrfs_suffix" "$mnt_root"/.snapshots
chmod 750 "$mnt_root"/.snapshots
chown :wheel "$mnt_root"/.snapshots
mount -o "$btrfs_options,subvol=@home" "$disk_dev$btrfs_suffix" "$mnt_root"/home
mount -o "$btrfs_options,subvol=@var_log" "$disk_dev$btrfs_suffix" "$mnt_root"/var/log
mount -o "$btrfs_options,subvol=@pkg" "$disk_dev$btrfs_suffix" "$mnt_root"/var/cache/pacman/pkg
mount -o "$btrfs_options,subvol=@libvirt" "$disk_dev$btrfs_suffix" "$mnt_root"/var/lib/libvirt/images
mount -o "$btrfs_options,subvol=@swap" "$disk_dev$btrfs_suffix" "$mnt_root"/swap

chattr +C "$mnt_root"/var/lib/libvirt/images

btrfs filesystem mkswapfile --size "$swap_size"g "$mnt_root"/swap/swapfile
swapon "$mnt_root"/swap/swapfile
