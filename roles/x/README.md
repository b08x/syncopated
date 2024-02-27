# x

Window manager agnostic - supports many WMs

This allows playbook authors to declaratively configure the full X system, GPU drivers and window managers while reusing common tasks. Vars allow flexibility per target based on hardware.

The role provides an Ansible-driven approach to repeatably deploy visual environments at scale. Its structure, defaults and parameters promote modularity, extensibility and deployability.


## The "x" role provides the functionality to install and configure a basic X11 desktop environment including:

* Installing Xorg server and driver packages as well as any host-specific video driver packages (i.e. nvidia, amd, intel)
* Configuring the xorg.conf file from a template
* Disabling vblanking by copying a .drirc file
* Generating and installing X11 configs like .xinitrc, .xprofile, etc from templates
* Ensuring the user is in the "video" group
* Configuring the video modules in mkinitcpio
* Importing the sxhkd task to configure keybindings
* Importing xdg tasks to configure desktop environment profiles
* Installing X utilities like xrandr, arandr

## The "x" role uses the following variables:

Variables are defined in roles/x/vars/main.yml and can be overridden per host

Default variables are set in roles/x/defaults/main.yml

Host-specific variables can be set in host_vars/*.yml

`{{ packages.xorg }}` - Contains list of base Xorg packages. Declared elsewhere.
`{{ host.xorg.video }}` - Specific video driver package if defined. Declared per host.
`{{ user.home }}` - User's home directory. Declared in common_vars.yml
`{{ user.name }}` - User name. Declared in common_vars.yml
`{{ user.group }}` - User's group. Declared in common_vars.yml
`{{ distribution }}` - OS distribution. Declared elsewhere.


* Files - Contains templates for X configuration files like xorg.conf
* Tasks - Main tasks are in tasks/main.yml, includes are used to split logic
* Templates - templates/ renders config files from variable input
* Vars - Variables for package names, drivers, configs
* Defaults - Default var values for things like video card, driver


Define common/per-host configurations
Are accessed via templates that generate config files
Are used within tasks to conditionalize operations
This allows declarative, repeatable X provisioning across different hardware using a single role definition. 

