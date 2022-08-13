#!/bin/bash

set -Eeo pipefail

vm_name='arch-ansible'
iso_path="$1"
base_path="$(dirname "$(realpath "$0")")"

export LIBVIRT_DEFAULT_URI='qemu:///system'

cd "$base_path"

dom_state="$( (virsh domstate "$vm_name" 2>/dev/null || printf 'undefined') | xargs)"

if [[ "$dom_state" = 'undefined' ]]
then
    if [ -z "$iso_path" ]
    then
        echo 'vm not installed. specify iso file to install vm.'
        exit 1
    else
        virt-install \
            --name="$vm_name" \
            --memory=8192 \
            --vcpus=4 \
            --disk='size=50' \
            --disk="$iso_path,device=cdrom,format=iso" \
            --filesystem="$base_path,base_path" \
            --osinfo='detect=on,name=archlinux' \
            --boot='cdrom,hd' \
            --boot=uefi \
            --network='network=default' \
            --qemu-commandline='-netdev user,id=mynet.0,net=10.0.10.0/24,hostfwd=tcp::22222-:22 -device rtl8139,addr=4,netdev=mynet.0' \
            --graphics=spice \
            --sound=default \
            --audio='id=1,type=spice' \
            --events='on_poweroff=destroy,on_reboot=restart,on_crash=destroy' \
            --autoconsole=none
        dom_state='running'
    fi
elif [[ "$dom_state" = 'shut off' ]]
then
    virsh start "$vm_name"
    dom_state='running'
fi

if [[ "$dom_state" = 'running' ]]
then
    virt-viewer --auto-resize=always -r arch-ansible
fi
