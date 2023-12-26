# syncopatedIaC

# support/distros branch
leaving this here should the need arise to include support for other distros, mainly Debian & RHEL based

An exercise in configuration management. Intended to serve as an IaC framework for a small lab or studio.

Based on Ansible, the repository contains roles, playbooks, and modules to help configure and manage Linux hosts that are part of an audio production workflow.

## directory index

| Path                      | Content                                     |     |
| :------------------------ | :------------------------------------------ | --- |
| [bin](bin/)               | Shell scripts                               |     |
| [docs](docs/)             | Documentation                               |     |
| [files](files/)           | Additional Files not included in roles      |     |
| [group_vars](group_vars/) | Variables for Host Groups                   |     |
| [host_vars](host_vars/)   | Variables for Hosts                         |     |
| [playbooks](playbooks/)   | Ansible Playbooks                           |     |
| [plugins](plugins/)       | Ansible Plugins and Modules                 |     |
| [roles](roles/)           | Ansible Roles                               |     |
| [tasks](tasks/)           | Additional tasks not included in roles      |     |
| [templates](templates/)   | Additional templates not included in roles  |     |
| [vars](vars/)             | Variables to include in playbooks and tasks |     |
| ansible.cfg               | Ansible configuration file                  |     |
| inventory.ini             | Host inventory                              |     |

## variables

### group_vars

all.yml - variables applied to all hosts

server.yml - variables applied to hosts in the server group

workstation.yml - variables applied to hosts in workstation group

### host_vars

variables for individual hosts

### vars

{{ distro }}/packages.yml - package lists

theme.yml - theme variables

### role variables

#### defaults/main.yml

-   These variables are intended to provide default values that can be overridden by the user or in other levels of precedence.

-   Role defaults are automatically loaded by Ansible, and their values serve as the default configuration for the role.

-   If a variable is not defined elsewhere in the playbook, Ansible will use the value specified in the role defaults.

#### vars/main.yml

-   These variables are meant to be set by the user or in the playbook to customize the behavior of the role.

-   Role variables take precedence over role defaults. If the same variable is defined in both role defaults and role variables, the value from role variables will be used.

-   Role variables allow users to customize the role without modifying the role's default behavior.

# demo

[![asciicast](https://asciinema.org/a/622463.svg)](https://asciinema.org/a/622463)

# testing

#TODO:

- [ ] [distrobox](https://github.com/89luca89/distrobox)

- [ ] [vagrant](https://github.com/hashicorp/vagrant)

- [ ] yadm
