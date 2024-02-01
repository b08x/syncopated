# syncopatedIaC

An exercise in configuration management. Intended to serve as an IaC framework for a small lab or studio.

The project uses Ansible to configure and maintain workstations and servers used in an audio production workflow. It encompasses a collection of roles which articulate the desired state of the infrastructure, encompassing software packages, services, and configurations essential for an optimal audio production environment.



## Directory Index

| Path                      | Content                                     |     |
| :------------------------ | :------------------------------------------ | --- |
| [bin](bin/)               | Shell scripts                               |     |
| [docs](docs/)             | Documentation                               |     |
| [files](files/)           | Additional Files not included in roles      |     |
| [group_vars](group_vars/) | Variables for Host Groups                   |     |
| [host_vars](host_vars/)   | Variables for Hosts                         |     |
| [playbooks](playbooks/)   | Playbooks                                   |     |
| [plugins](plugins/)       | Plugins and Modules                         |     |
| [roles](roles/)           | Roles                                       |     |
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


# demo

[![asciicast](https://asciinema.org/a/622463.svg)](https://asciinema.org/a/622463)

# testing

#TODO:

- [ ] migrate yadm managed configs to ansible
