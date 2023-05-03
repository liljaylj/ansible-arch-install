#!/bin/bash

disk_dev="${1:-/dev/vda}"
boot_suffix="${2:-1}"
btrfs_suffix="${3:-2}"
mnt_root="${4:-/mnt}"
btrfs_options='defaults,discard=async,compress-force=zstd,noatime'

sgdisk -g -t ef00 -n 1::+512MiB "$disk_dev"
sgdisk -g -t 8300 -N 2 "$disk_dev"

mkfs.fat -F32 -n LINUXEFI "$disk_dev$boot_suffix"
mkfs.btrfs -m dup -f -L Arch "$disk_dev$btrfs_suffix"

mount -o "$btrfs_options" "$disk_dev$btrfs_suffix" "$mnt_root"

btrfs subvol create /mnt/@
btrfs subvol create /mnt/@snapshots
btrfs subvol create /mnt/@home
btrfs subvol create /mnt/@var_log
btrfs subvol create /mnt/@pkg
btrfs subvol create /mnt/@libvirt
btrfs subvol create /mnt/@swap

umount "$mnt_root"
