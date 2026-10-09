#!/usr/bin/env bash
set -euo pipefail

MANAGED_HOST="${1:?usage: setup_ansible.sh <managed-node-ip>}"
MANAGED_USER="ubuntu"
KEY_PATH="/home/ubuntu/.ssh/ansible_key"
ANSIBLE_DIR="/home/ubuntu/ansible"

export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -y
sudo apt-get install -y ansible

sudo -u ubuntu ansible-galaxy collection install community.docker --force

mkdir -p "$ANSIBLE_DIR"
cd "$ANSIBLE_DIR"

cat > ansible.cfg <<'CFG'
[defaults]
inventory = hosts
host_key_checking = False
retry_files_enabled = False
interpreter_python = auto_silent

[ssh_connection]
pipelining = True
CFG

cat > hosts <<EOF
[web]
${MANAGED_HOST} ansible_user=${MANAGED_USER}

[web:vars]
ansible_ssh_private_key_file=${KEY_PATH}
ansible_python_interpreter=/usr/bin/python3
EOF

cat > playbook.yml <<'PLAY'
---
- name: Install Docker and deploy nginx
  hosts: web
  become: true
  tasks:
    - name: Update apt cache
      ansible.builtin.apt:
        update_cache: true

    - name: Install Docker prerequisites
      ansible.builtin.apt:
        name:
          - ca-certificates
          - curl
          - gnupg
        state: present

    - name: Create apt keyrings directory
      ansible.builtin.file:
        path: /etc/apt/keyrings
        state: directory
        mode: "0755"

    - name: Add Docker GPG key
      ansible.builtin.get_url:
        url: https://download.docker.com/linux/ubuntu/gpg
        dest: /etc/apt/keyrings/docker.asc
        mode: "0644"

    - name: Add Docker apt repository
      ansible.builtin.apt_repository:
        repo: "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu {{ ansible_distribution_release }} stable"
        filename: docker
        state: present

    - name: Install Docker Engine
      ansible.builtin.apt:
        name:
          - docker-ce
          - docker-ce-cli
          - containerd.io
          - docker-compose-plugin
        state: present
        update_cache: true

    - name: Ensure Docker is running and enabled
      ansible.builtin.service:
        name: docker
        state: started
        enabled: true

    - name: Run nginx container
      community.docker.docker_container:
        name: nginx
        image: nginx:latest
        state: started
        restart_policy: always
        ports:
          - "80:80"
PLAY

chown -R ubuntu:ubuntu "$ANSIBLE_DIR"

echo "Ansible controller ready. Run: cd $ANSIBLE_DIR && ansible-playbook playbook.yml"
