# Variable Usage in the SyncopatedIac Project

## Group Variables
- `all.yml`: Variables applied to all hosts
- `server.yml`: Variables applied to hosts in the server group
- `workstation.yml`: Variables applied to hosts in workstation group

## Host Variables
- Individual host-specific variables

## Vars
- `vars/{{ distro }}/packages.yml`: Package lists
- `var/stheme.yml`: Theme variables

## Role Variables

### defaults/main.yml
- These variables provide default values that can be overridden by the user or in other levels of precedence.
- Role defaults are automatically loaded by Ansible, serving as the default configuration for the role.
- If a variable is not defined elsewhere in the playbook, Ansible will use the value specified in the role defaults.

### vars/main.yml
- These variables are meant to be set by the user or in the playbook to customize the behavior of the role.
- Role variables take precedence over role defaults. If a variable is defined in both role defaults and role variables, the value from role variables will be used.
