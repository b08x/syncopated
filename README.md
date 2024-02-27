<h1 align="center">
  <br>
  <img height="300" src="https://github.com/b08x/syncopatedIaC/blob/development/docs/pixelcrow03.png?raw=true"> <br>
    SyncopatedIac
<br>
</h1>

An exercise in Linux Desktop Configuration Management. Intended to serve as an IaC framework to articulate the desired state of a small lab or studio.

The configuration management issues related to the Linux operating system include a lack of standardization and alignment on compatible distributions, making it difficult to pool efforts and build on a common foundation. There is also a need for the community to come together and share knowledge to create a repository of configuration guides, best practices, and tutorials. This will help ensure the future of Linux as a sustainable platform for studio workstations and provide the best artist experience on professional graphics workstations.

The project contains Ansible roles, playbooks, and modules designed to help maintain optimized configurations for Linux hosts that are used in an audio production workflow.

You can create playbooks that define the desired settings for each application, such as audio preferences, plugin configurations, or project templates. By using Ansible, you can easily apply these configurations across multiple machines, ensuring consistency and reducing manual effort.

Many audio production workflows rely on various plugins for effects, virtual instruments, or signal processing. Ansible Collections can assist in managing these plugins by automating their installation, updates, and configurations. You can define the desired set of plugins for each machine or project and use Ansible to ensure they are consistently available across your studio environment.

Audio production software often has specific dependencies or requirements. Ansible Collections can help manage these dependencies by automating the installation of required libraries or packages. This ensures that all necessary dependencies met on each machine, avoiding compatibility issues or missing components.

Ansible Collections can provide modules and playbooks to automate the configuration of audio interfaces, sound cards, MIDI controllers, and other hardware devices. You can define the desired settings for each device and use Ansible to ensure consistent configurations across your studio machines.

If you have a networked audio setup with multiple machines collaborating on projects, Ansible Collections can help you automate the configuration of network settings, synchronization protocols, and audio streaming setups. You can create collections that include roles and playbooks specific to your networked audio requirements.

The initial design is based around the i3 window manager, which is a keyboard-driven window manager. While roles are in place to support other environments like GNOME or XFCE, additional modifications would be required in the future to fully support those desktops.

The project itself is mostly an experiment and something I use for testing purposes. The idea is to hopefully demonstrate possibilities.

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

#TODO:

- [ ] migrate yadm managed configs to ansible
