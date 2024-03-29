#!/bin/env bash

set -Eexo pipefail

base_path="$(dirname "$(realpath "$0")")"
cd "$base_path"
export LIBVIRT_DEFAULT_URI='qemu:///system'

vm_name='arch-ansible'
for arg in "$@"; do
	if [[ "$arg" = '-v' ]]; then
		virt_viewer=1
	else
		iso_path="$arg"
	fi
done

if ! virsh net-list --name | rg -q '^default$'; then
	virsh net-start --network default
fi

dom_state="$( (virsh domstate "$vm_name" 2>/dev/null || printf 'undefined') | xargs)"

if [[ -n "$iso_path" ]]; then
	if [[ "$dom_state" = 'undefined' ]]; then
		virt-install \
			--name="$vm_name" \
			--memory=8192 \
			--vcpus='sockets=1,cores=2,threads=2' \
			--cpu='host-passthrough,cache.mode=passthrough' \
			--disk='size=50' \
			--cdrom="$iso_path" \
			--pm 'suspend_to_disk.enabled=on,suspend_to_mem.enabled=on' \
			--filesystem="$base_path,base_path" \
			--osinfo='detect=on,name=archlinux' \
			--boot=uefi \
			--network='network=default' \
			--qemu-commandline='-netdev user,id=mynet.0,net=10.0.10.0/24,hostfwd=tcp::22222-:22 -device rtl8139,addr=4,netdev=mynet.0' \
			--graphics=spice \
			--sound=default \
			--audio='id=1,type=spice' \
			--events='on_poweroff=destroy,on_reboot=restart,on_crash=destroy' \
			--autoconsole=none
		dom_state='running'
	elif [[ "$dom_state" = 'running' ]]; then
		virsh destroy "$vm_name"
		dom_state='shut off'
	fi
	if [[ "$dom_state" = 'shut off' ]]; then
		virt-install \
			--reinstall="$vm_name" \
			--cdrom="$iso_path" \
			--autoconsole=none
		dom_state='running'
	fi
else
	if [[ "$dom_state" = 'undefined' ]]; then
		echo 'vm not installed. specify iso file to install vm.'
		exit 1
	elif [[ "$dom_state" = 'shut off' ]]; then
		virsh start "$vm_name"
		dom_state='running'
	fi
fi

if [[ -n "$virt_viewer" && "$dom_state" != 'undefined' ]]; then
	virt-viewer --auto-resize=always -rs arch-ansible
fi
