#!/bin/bash
set -euxo pipefail

echo "LEVEL4: starting Ansible bootstrap"

# Basic bootstrap: update packages and install Ansible.
dnf upgrade -y
dnf install -y ansible-core

# Store the playbook at a predictable location.
mkdir -p /opt/level3

cat > /opt/level3/config-and-deploy.web.yml <<'EOA'
---
- name: Configure and deploy the Level 4 website
  hosts: localhost
  connection: local
  become: true
  gather_facts: true

  vars:
    ansible_python_interpreter: "{{ ansible_playbook_python }}"
    application_directory: /opt/level3/source
    web_directory: /usr/share/nginx/html

  tasks:
    - name: Install Nginx and Git
      ansible.builtin.dnf:
        name:
          - nginx
          - git
        state: present
        update_cache: true
        lock_timeout: 180

    - name: Download the application repository
      ansible.builtin.git:
        repo: https://github.com/nenemustafa/Hellome.git
        dest: "{{ application_directory }}"
        version: main
        update: true

    - name: Check that the webpage source exists
      ansible.builtin.stat:
        path: "{{ application_directory }}/heyme"
      register: webpage_source

    - name: Require the expected webpage file
      ansible.builtin.assert:
        that:
          - webpage_source.stat.exists
          - webpage_source.stat.isreg | default(false)
        fail_msg: "The repository does not contain the expected heyme file."

    - name: Deploy the webpage as index.html
      ansible.builtin.copy:
        src: "{{ application_directory }}/heyme"
        dest: "{{ web_directory }}/index.html"
        owner: root
        group: root
        mode: "0644"

    - name: Validate Nginx configuration
      ansible.builtin.command: nginx -t
      changed_when: false

    - name: Start Nginx and enable it at boot
      ansible.builtin.systemd:
        name: nginx
        state: started
        enabled: true

    - name: Wait for the local website to respond
      ansible.builtin.uri:
        url: http://127.0.0.1/
        status_code: 200
        return_content: true
        use_proxy: false
      register: homepage
      retries: 10
      delay: 3
      until: (homepage.status | default(0)) == 200

    - name: Verify the deployed greeting
      ansible.builtin.assert:
        that:
          - "'hey me!' in (homepage.content | lower)"
        fail_msg: "HTTP works, but the expected webpage was not returned."

    - name: Record successful deployment
      ansible.builtin.copy:
        dest: /var/lib/level4-deploy.complete
        content: "Ansible configuration and deployment succeeded.\n"
        owner: root
        group: root
        mode: "0644"
EOA

# Check the playbook before executing it.
ansible-playbook \
  -i 'localhost,' \
  --syntax-check \
  /opt/level3/config-and-deploy.web.yml

# Configure and deploy on this EC2 instance.
ansible-playbook \
  -i 'localhost,' \
  /opt/level3/config-and-deploy.web.yml

echo "LEVEL4: Ansible configuration and deployment completed successfully"
