#!/bin/bash

set -Eeo pipefail

base_path="$(dirname "$(realpath "$0")")"

cd "$base_path"

# # gather facts
# ansible default -m setup -i "$base_path/inventories/local/hosts.yml"

# run install playbook
ansible-playbook -i "$base_path/inventories/local/hosts.yml" install.yml
