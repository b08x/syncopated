# syncopated

Intended to serve as an automated infrastructure-as-code management framework for small labs or studios. Based on Ansible, the collection contains roles, playbooks, and modules to help configure and manage Linux hosts that are part of an audio production workflow.


|    Path                        |    Content                                                               |
|:-------------------------------|:-------------------------------------------------------------------------|
|    bin/                        |    Shell scripts                                                         |
|    docs/                       |    This documentation                                                    |
|    files/                      |    Additional Files not included in roles                                |
|    group_vars/                 |    Ansible group_vars                                                    |
|    host_vars/                  |    Ansible host_vars                                                     |
|    playbooks/                  |    Ansible Playbooks                                                     |
|    plugins/                    |    Plugins and Modules                                                   |
|    roles/                      |    Custom Ansible Roles                                                  |
|    tasks/                      |    Additional tasks not included in roles                                |
|    templates/                  |    Additional templates not included in roles                            |
|    vars/                       |    Ansible variables for custom playbooks and roles                      |
|    logs/                       |    Execution logs                                                        |
|    ansible.cfg                 |    Ansible configuration file                                            |
|    inventory.ini               |    Host inventory                                                        |




## defaults/main.yml

 * These variables are intended to provide default values that can be overridden by the user or in other levels of precedence.

 * Role defaults are automatically loaded by Ansible, and their values serve as the default configuration for the role.

 * If a variable is not defined elsewhere in the playbook, Ansible will use the value specified in the role defaults.

## vars/main.yml

 * These variables are meant to be set by the user or in the playbook to customize the behavior of the role.

 * Role variables take precedence over role defaults. If the same variable is defined in both role defaults and role variables, the value from role variables will be used.

 * Role variables allow users to customize the role without modifying the role's default behavior.




If a variable is set in a role variable (vars/main.yml)

