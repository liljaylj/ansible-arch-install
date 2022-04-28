#!/bin/bash

set -Eeo pipefail

vm_name='arch-ansible'
iso_path="$1"
base_path="$(dirname "$(realpath "$0")")"

cd "$base_path"

if ! virsh --connect qemu:///system domstate "$vm_name" >/dev/null 2>&1
then
    if [ -z "$iso_path" ]
    then
        echo 'vm not installed. specify iso file to install vm.'
        exit 1
    else
        virt-install --connect=qemu:///system \
            --name="$vm_name" \
            --memory=8192 \
            --vcpus=4 \
            --disk='size=20' \
            --cdrom="$iso_path" \
            --osinfo='detect=on,require=on' \
            --boot='cdrom,hd' \
            --boot=uefi \
            --network=none \
            --qemu-commandline='-netdev user,id=mynet.0,net=10.0.10.0/24,hostfwd=tcp::22222-:22 -device rtl8139,netdev=mynet.0' \
            --graphics=spice \
            --sound=default \
            --audio='id=1,type=spice' \
            --events='on_poweroff=destroy,on_reboot=restart,on_crash=destroy' \
            --autoconsole=graphical
    fi
fi

# # gather facts
# ansible default -m setup -i "$base_path/inventories/libvirt/hosts.yml"

# run install playbook
ansible-playbook -i "$base_path/inventories/libvirt/hosts.yml" install.yml
