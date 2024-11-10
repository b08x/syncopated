# Ansible Collections

Here's how to use these collections in practice:

1. **Install Collections**:

```bash
# Create requirements.yml file with your collection dependencies
ansible-galaxy collection install -r requirements.yml

# For local development, you can install from the local build
ansible-galaxy collection install path/to/custom-system_core-1.0.0.tar.gz
```

2. **Reference Collections in Playbooks**:

There are several ways to use collections in your playbooks:

```yaml
# Method 1: Using collections keyword at playbook level
---
- name: Setup Workstation
  hosts: workstations
  collections:
    - custom.system_core
    - custom.desktop_environment
  tasks:
    - name: Configure base system
      import_role:
        name: base
    
    - name: Setup desktop environment
      import_role:
        name: gnome

# Method 2: Using Fully Qualified Collection Names (FQCN)
---
- name: Setup Workstation
  hosts: workstations
  tasks:
    - name: Configure base system
      import_role:
        name: custom.system_core.base
    
    - name: Setup desktop environment
      import_role:
        name: custom.desktop_environment.gnome
```

3. **Create Task Files Using Collections**:

```yaml
# tasks/setup_workstation.yml
---
- name: Install base packages
  ansible.builtin.include_role:
    name: custom.system_core.base
  vars:
    packages:
      - git
      - curl
      - vim

- name: Configure desktop environment
  block:
    - name: Setup window manager
      ansible.builtin.include_role:
        name: custom.desktop_environment.i3
      when: use_i3 | default(false) | bool

    - name: Configure theme
      ansible.builtin.include_role:
        name: custom.desktop_environment.theme
      vars:
        theme_name: "nordic"
```

4. **Using Collection Variables**:

```yaml
# group_vars/workstations.yml
---
# System Core Collection variables
system_core_users:
  - username: developer
    groups: ['docker', 'sudo']
    shell: /bin/zsh

# Desktop Environment Collection variables
desktop_environment_config:
  theme: nordic
  cursor_theme: breeze
  icon_theme: papirus
  font_size: 10
  terminal_font: "JetBrains Mono"

# Development Tools Collection variables
development_tools_config:
  docker_users: ['developer']
  vscode_extensions:
    - ms-python.python
    - hashicorp.terraform
```

5. **Creating Environment-Specific Playbooks**:

```yaml
# development.yml
---
- name: Import base configuration
  import_playbook: base.yml

- name: Configure Development Environment
  hosts: development_workstations
  collections:
    - custom.development_tools
  roles:
    - role: vscode
      vars:
        vscode_extensions: "{{ development_tools_config.vscode_extensions }}"
    
    - role: docker
      vars:
        docker_users: "{{ development_tools_config.docker_users }}"

# audio-workstation.yml
---
- name: Import base configuration
  import_playbook: base.yml

- name: Configure Audio Workstation
  hosts: audio_workstations
  collections:
    - custom.audio_production
  roles:
    - role: jackd
      vars:
        realtime_priority: true
        period_size: 128
    
    - role: pipewire
      vars:
        sample_rate: 48000
        quantum_size: 128
```

6. **Using Tags with Collections**:

```yaml
# site.yml
---
- name: Configure System
  hosts: all
  collections:
    - custom.system_core
    - custom.desktop_environment
  tasks:
    - name: Basic system setup
      import_role:
        name: base
      tags: ['system', 'base']

    - name: Configure desktop
      import_role:
        name: gnome
      tags: ['desktop', 'gui']

# Run specific parts using tags:
ansible-playbook site.yml --tags "desktop"
```

7. **Using Collection Handlers**:

```yaml
# roles/task_file.yml
---
- name: Update desktop configuration
  ansible.builtin.template:
    src: custom.desktop_environment.theme/templates/theme.conf.j2
    dest: /etc/theme.conf
  notify: custom.desktop_environment.theme.reload_theme

# roles/handlers/main.yml
---
- name: Import theme handlers
  ansible.builtin.import_role:
    name: custom.desktop_environment.theme
    tasks_from: handlers
```

8. **Testing Collection Usage**:

```bash
# Test specific roles
ansible-playbook site.yml --check --diff --tags "desktop"

# Test with specific variables
ansible-playbook site.yml -e "use_i3=true theme_variant=dark"

# Limit to specific hosts
ansible-playbook site.yml --limit "workstations"
```

9. **Debugging Collection Usage**:

```bash
# Show collection search paths
ansible-config dump | grep COLLECTIONS_PATH

# List installed collections
ansible-galaxy collection list

# Verify collection content
ansible-galaxy collection verify custom.system_core

# Get collection help
ansible-doc -l | grep custom.
```

