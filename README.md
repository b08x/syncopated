# syncopatedIaC

An exercise in configuration management. Intended to serve as an IaC framework for a small lab or studio.

The repository contains Ansible roles, playbooks, and modules to help configure and manage Linux hosts that are part of an audio production workflow.

## Directory Index

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



### Using Tags

```bash

ansible-playbook -i inventory.ini playbooks/full.yml --tags $TAGS --limit $HOSTNAME

```


# demo

[![asciicast](https://asciinema.org/a/622463.svg)](https://asciinema.org/a/622463)

# testing

#TODO:

- [ ] [distrobox](https://github.com/89luca89/distrobox)

- [ ] [vagrant](https://github.com/hashicorp/vagrant)

- [ ] yadm
