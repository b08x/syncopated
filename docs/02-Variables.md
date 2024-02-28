# The Variables and Where To Set Them

## Group Variables

- `all.yml`: Variables applied to all hosts
- `server.yml`: Variables applied to hosts in the server group
- `workstation.yml`: Variables applied to hosts in workstation group

Here's a breakdown of where a variable declared in `group_vars/workstation.yml` could be overwritten, listed in order of increasing precedence:
  1. Group Variables (More Specific):
      group_vars/*: Variables defined in group_vars files for groups that take precedence over the "workstation" group. Consider how your inventory is structured and any nested group relationships.

  1. **Inventory host_vars/*:**
   * Variables defined in a `host_vars` file  for a specific host in the 'workstation' group would take precedence.

3. **Playbook Variables:**
   * **Play vars:**  Variables defined in your playbook's `vars` section.
   * **Play vars_prompt:** Variables requested from the user at runtime using the  `vars_prompt` section.
   * **Play vars_files:** Variables loaded from external files using the `vars_files` section.

4. **Blocks and Tasks:**
   * **Block vars:** Variables defined within a `block` in your playbook (only affecting tasks within that block).
   * **Task vars:** Variables defined directly inside a task.

5. **Include Variables:**
   * **include_vars:**  Variables loaded from external files using the `include_vars` module.

6. **Facts and Registered Variables:**
   * **host facts / cached set_facts:** Discovered host facts or facts  manually set using the `set_fact` module with the same name as one of your `group_vars/workstation.yml` variables would override it.
   * **register:** The `register` module captures output from a task and stores it as a variable. If this matches the name of a variable from `group_vars/workstation.yml`, the registered value takes precedence.

7. **Extra Variables (command line):**
   * Variables passed at runtime using the `-e` flag when executing the Ansible playbook have the absolute highest precedence.

**Key Points:**

* **Group Scope:** Variables in `group_vars/workstation.yml` apply to all hosts within the "workstation" group.
* **Host Specificity:** Host variables always override group variables for individual hosts.

**Let me know if you want to dive into a specific example or explore scenarios with more complex group hierarchies!**


**How It Fits Together**

1. **A role defines its basic structure:**  Variables set in `defaults/main.yml` and `vars/main.yml`.
2. **Your inventory applies these roles:** Hosts are placed in groups with `group_vars` possibly setting variables including those that might be defined in the roles.
3. **Playbooks customize further:** Your Ansible playbooks can introduce variables that take precedence for specific tasks or blocks.

**Key Summary:**

* **Layered System:** Think of Ansible's variable precedence as layers, with each layer having the potential to override the layers below it.
* **Context Matters:** The most appropriate place to define a variable depends on the scope and how much flexibility you need for overriding it in different playbooks and inventories.

**Example:**

* **Role 'webserver' default for port:**  `defaults/main.yml`: `webserver_port: 80`
* **Change port generally for workstations:** `group_vars/workstation.yml`: `webserver_port: 8080`
* **Override for a specific server:** `host_vars/specialserver.yml`: `webserver_port: 8443`




## Host Variables

- Individual host-specific variables




## Vars

- `vars/{{ distro }}/packages.yml`: Package lists
- `var/stheme.yml`: Theme variables



# roles

### Role Variables

* **Medium Precedence:**  Variables declared in a role's `vars/main.yml` file override role defaults. However, they are still subject to being overridden by:
   * Group variables from a more specific group the host is a part of
   * Host variables
   * Playbook variables
   * ....

If you declare a variable in your `vars/main.yml` file for a role, here's the breakdown of where it could be overwritten, listed in order of increasing precedence:


2. **Inventory Variables:**
   * **Group vars:** Variables within `group_vars` directories that correspond to groups your host is a member of.
   * **Host vars:** Variables within a `host_vars` file specifically for the host the role is applied to.

3. **Playbook Variables:**
   * **Play vars:**  Variables defined within your playbook using the `vars` section.
   * **Play vars_prompt:** Variables requested at runtime from the user using the `vars_prompt` section.
   * **Play vars_files:** Variables loaded from external files using the `vars_files` section.

4. **Block and Task Variables:**
   * **Block vars:** Variables defined within a `block` in your playbook, but only within the scope of that block.
   * **Task vars:** Variables defined directly inside a task.

5. **Include Variables:**
   * **include_vars:**  Variables loaded from files you import using the `include_vars` module.

6. **Facts and Registered Variables:**
   * **host facts / cached set_facts:** A discovered host fact or a manually set fact using the `set_fact` module with the same name as one of your variables would override it.
   * **register:** The `register` module captures the output of a task and stores it as a variable. If the variable name matches one of your `vars/main.yml` variables, this value would take precedence.

7. **Extra Variables (command line):**
   * Variables passed from the command-line using the `-e` flag when executing the Ansible playbook have the absolute highest precedence.

**Key Points**

* Variables in `vars/main.yml` act as a more specific configuration layer than defaults but still fall within the role's boundaries.
* Ansible's precedence rules ensure you can flexibly override variables as needed in your playbooks or inventories.

**Let me know if you'd like a specific example of how to override a variable declared in `vars/main.yml`!**


### Role Defaults

If you have a variable declared in `defaults/main.yml` (within a role), here's where it could be overwritten, in order of increasing precedence:

* **Lowest Precedence:** Role defaults are the foundation, providing the baseline values for variables within a role. Anything we've discussed above will override role defaults.


1. **Role Variables (Other Locations):**
   * **vars/main.yml:**  Variables in your role's `vars/main.yml` file would override defaults.
   * **Other role-specific vars files:** Variables in other `vars` files created for the same role would take precedence.

2. **Inventory Variables:**
   * **Inventory group_vars/*:** Variables in `group_vars` directories that correspond to groups your host is a member of.
   * **Inventory host_vars/*:** Variables in a `host_vars` file specifically for the host the role is applied to.

3. **Playbook Variables:**
   * **Play vars:**  Variables defined within your playbook's `vars` section.
   * **Play vars_prompt:** Variables requested from the user at runtime using the `vars_prompt` section.
   * **Play vars_files:** Variables loaded from external files using the `vars_files` section.

4. **Blocks and Tasks:**
   * **Block vars:** Variables defined within a `block` in your playbook, but only within the scope of that block.
   * **Task vars:** Variables defined directly inside a task.

5. **Include Variables:**
   * **include_vars:**  Variables loaded from external files using the `include_vars` module.

6. **Facts and Registered Variables:**
   * **host facts / cached set_facts:** A discovered host fact or a manually set fact using the `set_fact` module with the same name as your default would override it.
   * **register:** The `register` module captures the output of a task and stores it as a variable. If the variable name matches one of your defaults, this value would take precedence.

7. **Extra Variables (command line):**
   * Variables passed at runtime using the `-e` flag when executing the Ansible playbook have the absolute highest precedence.

**Key Points**

* Role defaults act as the lowest-priority "base" for variable settings.
* Ansible's precedence rules provide granular control and flexibility within a structured framework.


### defaults/main.yml
- Role defaults are automatically loaded by Ansible, serving as the default configuration for the role.
- If a variable is not defined elsewhere in the playbook, Ansible will use the value specified in the role defaults.

### vars/main.yml
- These variables are meant to be set by the user or in the playbook to customize the behavior of the role.
- Role variables take precedence over role defaults. If a variable is defined in both role defaults and role variables, the value from role variables will be used.




* you can put user vars in `group_vars` or `$ANSIBLE_HOME/vars/users.yml`
