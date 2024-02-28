<h1 align="center">
  <br>
  <img height="300" src="https://github.com/b08x/syncopatedIaC/blob/development/docs/images/pixelcrow03.png?raw=true"> <br>
    SyncopatedIac
<br>
</h1>

SyncopatedIaC stands as an exercise in Linux Desktop Configuration Management, aiming to serve as an Infrastructure as Code (IaC) framework to articulate the desired state of a small lab or studio.

Addressing the challenges of configuration management within the Linux operating system, the project acknowledges the critical need for standardization, compatibility across distributions, and community collaboration. By fostering a repository of configuration guides, best practices, and tutorials, SyncopatedIaC aspires to demonstrate a sustainable platform for studio workstations, delivering an unparalleled artist experience within the Linux Audio eco-system.

At its core, the project leverages Ansible roles, playbooks, and modules to maintain optimized configurations for Linux hosts within an audio production workflow.

### Key Features:

- **Playbooks for Precise Configuration**: Define the precise audio settings, plugin configurations, or project templates for each application. Utilize Ansible to deploy these configurations effortlessly across multiple machines, ensuring consistency and reducing manual intervention.

**Example**: Creating a playbook to manage audio preferences involves specifying the desired settings within a YAML file. This could include the default audio input/output devices, sample rates, or buffer sizes. Applying the playbook across your studio machines ensures that each workstation adheres to these predefined settings.

- **Ansible Collections for Plugin Management**: Manage your audio production plugins by automating their installation, updates, and configurations. Define the essential plugins for each project or machine and utilize Ansible to consistently deploy these across your studio environment.

**Example**: Suppose you need a specific set of audio effects plugins for a project. You can define these in an Ansible Collection, including version numbers and configuration settings. Running the Ansible playbook will then ensure that these plugins are installed and configured across all designated workstations.

- **Dependency Management**: Automate the installation of libraries or packages required by audio production software. This automation ensures that all dependencies are met on each machine, circumventing potential compatibility issues or missing components.

**Example**: If an audio application requires a particular library version not present by default on your systems, Ansible can automate the installation process. By including this in your playbook, you can guarantee that every workstation in your studio is equipped with the necessary dependencies.

- **Hardware Configuration Automation**: Utilize Ansible to automate the configuration of audio interfaces, sound cards, MIDI controllers, and other hardware devices. Define desired device settings and ensure consistent configurations across your studio machines.

**Example**: You could create an Ansible role to configure a MIDI controller, specifying parameters such as the MIDI channel, control change (CC) numbers, and mappings. Applying this role across your studio ensures that every MIDI controller conforms to the same configuration.

- **Networked Audio Setup Automation**: For studios utilizing networked audio setups, Ansible Collections can automate the configuration of network settings, synchronization protocols, and audio streaming setups. Tailor roles and playbooks to your specific networked audio requirements.

**Example**: If your studio employs an audio-over-IP protocol, such as Dante or AVB, you can create playbooks that configure network interfaces, manage clock synchronization, and set up audio routing rules. This ensures seamless integration and operation of networked audio devices across your studio.

### Initial Design and Environment Support:

The project's initial design focuses on the i3 window manager, renowned for its efficiency and keyboard-driven operation. While existing roles support alternative environments like GNOME or XFCE, future enhancements are anticipated to extend comprehensive support to these desktops.

### The Project's Nature:

Primarily experimental, this project serves as a testbed for demonstrating the potential of IaC in managing Linux desktop configurations within an audio production context.


#### Ok

## Directory Index

| Path                      | Content                                     |     |
| :------------------------ | :------------------------------------------ | --- |
| [docs](docs/)             | An attempt at further Documentation         |     |
| [files](files/)           | Additional Files not included in roles      |     |
| [group_vars](group_vars/) | Variables for Host Groups                   |     |
| [host_vars](host_vars/)   | Variables for Hosts                         |     |
| [playbooks](playbooks/)   | Playbooks                                   |     |
| [plugins](plugins/)       | Plugins and Modules                         |     |
| [roles](roles/)           | Roles                                       |     |
| [scripts](scripts/)        | Various scripts to perform admin tasks     |     |
| [tasks](tasks/)           | Additional tasks not included in roles      |     |
| [templates](templates/)   | Additional templates not included in roles  |     |
| [vars](vars/)             | Variables to include in playbooks and tasks |     |
| ansible.cfg               | Ansible configuration file                  |     |
| inventory.ini             | Host inventory                              |     |

## Playbooks

* playbooks/full.yml: The main playbook, often run with various options.
* playbooks/homepage.yml: Playbook for setting up the homepage.
* playbooks/database.yml: Playbook for managing databases.
* playbooks/nas.yml: Playbook for setting up a NAS system.
* playbooks/pi.yml: Playbook for Raspberry Pi setups.
* playbooks/llmos.yml: Playbook for LLMOS tasks (unclear purpose).
* playbooks/llmops.yml: Playbook for LLMOPS tasks (likely typo of llmos).

## Commonly Used Options

--tags: Specify which tasks to run (e.g., network, desktop).

--limit: Target specific groups or hosts (e.g., soundbot, workstation).

--skip-tags: Exclude specific tasks.

-e: Extra variables passed to the playbook (e.g., update_mirrors=true, distribution=Archlinux).

--start-at-task: Specify the starting task within the playbook.

### Using Tags

```bash

ansible-playbook -i inventory.ini playbooks/full.yml --tags $TAGS --limit $HOSTNAME

```

For example

* The `audio` tag is used to install and configure audio packages on a system.
* When the `audio` tag is used, Ansible will run the following tasks:
  - The `alsa` role is used to install and configure the ALSA sound system.
  - The `pipewire` role is used to install and configure the PipeWire audio server.
  - The `jack` role is used to install and configure the JACK audio connection kit.
  - The `pulseaudio` role is used to install and configure the PulseAudio sound server.


# demo

[![asciicast](https://asciinema.org/a/622463.svg)](https://asciinema.org/a/622463)

# testing

```bash

ansible-inventory-grapher -i inventory.ini all -o "{}.dot" -a \
  "rankdir=LR; splines=ortho; ranksep=2;\
  node [ width=5 style=filled fillcolor=orange background=black ];\
  edge [ dir=back arrowtail=empty style="dashed" ];\
  bgcolor="darkgray";"


```

#TODO:

- [ ] migrate yadm managed configs to ansible
