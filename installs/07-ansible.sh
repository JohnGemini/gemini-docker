#!/bin/bash

apt-get install -y software-properties-common
apt-add-repository ppa:ansible/ansible
apt-get update
apt-get install -y ansible

sed -i 's|#retry_files_enabled = False|retry_files_enabled = False|g' /etc/ansible/ansible.cfg
sed -i 's|#stdout_callback = skippy|stdout_callback = json|g' /etc/ansible/ansible.cfg

