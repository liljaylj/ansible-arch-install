#!/bin/env bash

set -Eexo pipefail

vm_name='arch-ansible'

virsh destroy "$vm_name" || true
virsh undefine --nvram "$vm_name"
virsh vol-delete --pool default "$vm_name".qcow2
