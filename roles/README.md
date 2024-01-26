# roles

|  name                           |  description                                                   |
|:--------------------------------|:---------------------------------------------------------------|
|  [alsa](alsa/)                  | Installs packages, configures soundcards                       |
|  [applications](applications/)  | Installs applications                                          |
|  [audio](audio/)                | Configures hosts for RT tasks                                  |
|  [base](base/)                  | Configures repos, profile, environment                         |
|  [bash](bash/)                  | Configures bash profile                                        |
|  [desktop](desktop/)            | Installs desktop applications, configures xorg, window manager |
|  [docker](docker/)              | Installs and configures docker                                 |
|  [flowise](flowise/)            | Deploys flowise docker-compose                                 |
|  [gnome](gnome/)                | Placeholder for DE role                                        |
|  [greetd](greetd/)              | Configures greetd as display manager                           |
|  [i3](i3/)                      | Configures i3&nbsp;                                            |
|  [jack](jack/)                  | Installs jack2-dbus, configures service and jack_control       |
|  [libvirt](libvirt/)            | Configures kvm                                                 |
|  [lightdm](lightdm/)            | Installs and configures lightdm as display manager             |
|  [nas](nas/)                    | Configure a NFS or rsyncd host                                 |
|  [network](network/)            | Configures network cards                                       |
|  [packager](packager/)          | Builds Packages                                                |
| [pipewire](pipewire/)           | Installs and configures Pipewire                               |
|  [pulseaudio](pulseaudio/)      | Installs and configures pulseaudio                             |
|  [ruby](ruby/)                  | Installs rubygems and configures asdf                          |
|  [sway](sway/)                  | Installs and configures sway WM                                |
| [terminal](terminal/)           | Installs and configures terminal applications                  |
|  [theme](theme/)                | Installs and configures theme                                  |
|  [tuning](tuning/)              |                                                                |
|  [user](user/)                  |                                                                |
|  [wayland](wayland/)            | Placeholder&nbsp;                                              |
|  [xorg](xorg/)                  | Installs and configures xorg                                   |
| [zsh](zsh/)                     | Installs and configures zsh                                    |


# roles

The roles directory in Ansible contains different roles that can be included in a playbook to configure certain aspects or components of a system. Each role is self-contained and focuses on a specific task or domain.

The structure within each role directory is generally consistent and includes:

- README.md - Documents what the role does and how to use it.

- defaults/ - Default variable values.

- files/ - Static files used by the role.

- handlers/ - Handler definitions.

- templates/ - Template files rendered by the role.

- tasks/ - Main.yml containing the role's tasks.

- vars/ - Variables passed to the role.

- tests/ - Role tests.

- meta/ - Role dependencies.


Some examples roles provided are:

- alsa/ - Configure sound card and ALSA.

- i3/ - Install and configure i3 window manager.

- zsh/ - Configure Zsh shell.

- nas/ - Setup NFS shares for a NAS role.

- bash/ - Tasks related to Bash shell configuration.


Each role has a uniform structure and documention in the README file. This makes the roles reusable and easy to understand for playbook authors applying them. The roles provide modularization and logical grouping of related tasks into discrete units that can be mixed and matched across playbooks as needed.

---

The roles directory in Ansible is used to define roles, which are reusable groups of tasks, files, templates, and variables that can be included across playbooks. This allows for logical grouping and modularization of Ansible content.

Some of the key roles defined in the /syncopatedIaC/tests/testplaybook.yml file include:

base - This role handles basic system configuration and is likely applied to all hosts. Its vars/main.yml file sets an expected_value variable.

terminal - Configures terminal emulators like kitty and alacritty.

network - Configures network interfaces and connections.

ruby - Installs Ruby and related gems defined in the Gemfile.

audio - Configures audio packages and settings for audio applications. Roles like alsa, pipewire, jack further define audio stack configurations.

docker - Installs and configures Docker.

libvirt - Configures libvirt virtualization.

theme - Configure desktop themes.

desktop - Handles desktop environment, windows manager, and application configurations.

user - Configure user accounts and homes.

applications - Installs and configures additional desired applications.

So in summary, the roles directory allows grouping configurations by concern or domain into reusable roles that can be included across systems defined in the inventory to achieve a desired result. The roles eliminate duplication and make the playbook logic modular and maintainable.
