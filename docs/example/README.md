# setting up a new host

`bash <(curl http://github/b08x/syncopated/setup.sh)`

* installs ansible & galaxy collection

var files for each role are displayed for user to edit/change, 
those variable are stored in ~/.config/syncopated/vars.yml

```bash

docker container of target distro with additional repos is started 


***select packages to install using gum or fzf***



`prompt: select target distro`

`prompt: add any additional repos`

`prompt: add users`

`prompt: select window manager`

`prompt: edit/enter custom keybindings`

`prompt: select audio subsystem: jack|pipewire`

etc etc

```

Then when creating a playbook:

```yaml

- hosts: all
  vars_files: ~/.config/syncopated/vars.yml

- hosts: localhost
  vars_files: ~/.config/syncopated/host_vars/hostname.yml

- hosts: workstations
  vars_files: ~/.config/syncopated/group_vars/workstations.yml

```
