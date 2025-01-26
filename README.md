<img src="https://github.com/b08x/SyncopatedOS/blob/development/assets/workspace07.jpeg?raw=true">

# SyncopatedOS

SyncopatedOS is an Ansible-based system configuration and management toolkit designed to automate the setup and maintenance of various specialized Linux environments.

## Collections

The project is organized into the following collections:

- **audio_production**: Roles for configuring audio production environments including ALSA, JACK, PipeWire, and DAW setup
- **desktop_environment**: Desktop environment configuration roles
- **development_tools**: Development environment setup and tooling
- **llmops_dev**: LLM operations and development tools
- **media_tools**: Media processing and management tools
- **shell_environment**: Shell configuration and customization
- **storage**: Storage management and configuration
- **system_core**: Core system configuration roles
- **system_services**: System service management and configuration

## Playbooks

Available playbooks for different system configurations:

### Core Playbooks

- **base.yml**: Basic system setup including user configuration, shell setup, and networking
- **full.yml**: Complete system setup combining all major roles and configurations
- **utils.yml**: Utility scripts and tools installation

### Specialized Environments

- **daw.yml**: Digital Audio Workstation setup with audio system configuration
- **workstation.yml**: Desktop workstation setup with GUI applications and development tools
- **virt.yml**: Virtualization environment setup with Docker and KVM
- **nas.yml**: Network Attached Storage configuration
- **llmos.yml**: LLM operations system setup
- **homepage.yml**: System dashboard/homepage setup

### System Types

The playbooks support different types of system configurations:

1. **Base System**
   - Core system configuration
   - User management
   - Shell environment
   - Network setup

2. **Workstation**
   - Desktop environment (i3/GNOME)
   - Development tools
   - Media applications
   - Input device configuration

3. **Audio Production**
   - ALSA configuration
   - JACK audio server
   - PulseAudio setup
   - DAW tools and plugins

4. **Virtualization**
   - Docker configuration
   - KVM/libvirt setup
   - Development environments

## Usage

1. Clone the repository:
```bash
git clone https://github.com/b08x/dotfiles.git
```

2. Install requirements:
```bash
pip install -r requirements.txt
```

3. Run a playbook:
```bash
ansible-playbook playbooks/[playbook].yml
```

Replace `[playbook]` with the desired configuration (e.g., base.yml, workstation.yml, daw.yml).

## Tags

Playbooks use tags for selective role execution. Common tags include:

- `base`: Basic system configuration
- `user`: User management
- `shell`: Shell environment setup
- `networking`: Network configuration
- `daw`: Audio production setup
- `i3`/`gnome`: Desktop environment configuration
- `applications`: General application installation
- `theme`: System theming and appearance

Example usage with tags:
```bash
ansible-playbook playbooks/full.yml --tags "base,networking"
