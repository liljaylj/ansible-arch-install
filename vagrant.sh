#!/bin/bash

set -Eeuo pipefail

base_path="$(dirname "$(realpath "$0")")"

cd "$base_path"

# NOTE: don't forget to install `vagrant plugin install vagrant-libvirt`
vagrant up --provider=libvirt
vagrant ssh-config > "$base_path/vagrant-ssh-config"

# # gather facts
# ansible default -m setup -i "$base_path/inventories/vagrant/hosts.yml"

# run install playbook
ansible-playbook -i "$base_path/inventories/vagrant/hosts.yml" config.yml
