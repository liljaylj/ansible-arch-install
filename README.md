## Running in libvirt VM

### Create VM

There is shell script to create/start VM. Run `./libvirt.sh`.

### virt-viewer

```shell
setfont ter-p22n  # increase font size
```

_press `F11` to enter fullscreen in virt-viewer_

### SSH

in virt-viewer:

```shell
passwd  # set password for root user
```

then, on host:

```shell
ssh -o 'UserKnownHostsFile=/dev/null' -o 'StrictHostKeyChecking=no' -p 22222 root@localhost
```

### Mount working folder

```shell
mkdir /src
mount -t 9p base_path /src
cd /src
```

## Install archlinux

### Archiso kernel parameters

Press "e" in systemd-boot menu and add these kernel parameters:

- Reserve more virtual disk space for archiso - `cow_spacesize=2G`
- Set videomode to fhd - `video=1920x1080@60m`

### Update mirrorlist

```shell
reflector -c KZ, -p http --completion-percent 99 -f 5 --save /etc/pacman.d/mirrorlist
```

### Install ansible and archinstall

```shell
pacman --noconfirm -Sy archinstall ansible
```

#### To be able copy/paste from terminal scrollback install tmux

```shell
pacman --noconfirm -S tmux
```

### Create disk layout and mount

```shell
archinstall --script only_hd
```

... or using shell script

```shell
bash partition.sh
```

### Install arch

```shell
ansible-playbook -i hosts.yml install.yml -e 'part_selector=PARTUUID=<root partition uuid>' --ask-vault-pass
```

> You can get PARTUUID of root partition by running `lsblk -no path,partuuid`

## Tips

### Vi-mode for bash

```shell
set -o vi
```

### Remove filesystem on disks

```shell
wipefs -a <block device path>
```

### Remove partitions

```shell
parted <root block device path> rm <partition number>
```

### Remove VM

#### Stop VM

```shell
virsh destroy arch-ansible
```

#### Delete VM

```shell
virsh undefine --nvram arch-ansible
```

#### Delete volume

```shell
virsh vol-delete --pool default arch-ansible.qcow2
```
