# x

The /syncopatedIaC/roles/x/tasks/main.yml file defines the tasks for the "x" role. The main tasks performed are:

Installing Xorg packages ({{ packages.xorg }}) and any host-specific video driver packages ({{ host.xorg.video }})
Configuring the xorg.conf file from a template
Disabling vblanking by copying a .drirc file
Generating and installing X11 configs like .xinitrc, .xprofile, etc from templates
Ensuring the user is in the "video" group
Configuring the video modules in mkinitcpio
Importing the sxhkd task to configure keybindings
Importing xdg tasks to configure desktop environment profiles
What variables are used by the "x" role and where are they declared?
The "x" role uses the following variables:

packages.xorg - Contains list of base Xorg packages. Declared elsewhere.
host.xorg.video - Specific video driver package if defined. Declared per host.
user.home - User's home directory. Declared in common_vars.yml
user.name - User name. Declared in common_vars.yml
user.group - User's group. Declared in common_vars.yml
distribution - OS distribution. Declared elsewhere.
What functionality does the "x" role provide?
The "x" role provides the functionality to install and configure a basic X11 desktop environment including:

Installing Xorg packages
Configuring the xorg.conf
Setting up basic X11 configs and keybindings
Adding the user to the "video" group for multimedia
Configuring mkinitcpio modules for the graphics driver
Tasks are also imported for firewall, sxhkd, and xdg to integrate those components into the X desktop environment.

---

###


The "x" role handles tasks related to configuring the X Window System environment. Some key things about its structure and content:

Files - Contains templates for X configuration files like xorg.conf

Tasks - Main tasks are in tasks/main.yml, includes are used to split logic

Templates - templates/ renders config files from variable input

Vars - Variables for package names, drivers, configs

Defaults - Default var values for things like video card, driver

## Common tasks include:

Installing Xorg server and driver packages for GPU (i.e. nvidia, amd, intel)

Generating xorg.conf files from templates

Setting environmental variables

Configuring display managers like LightDM, SDDM

Managing X services - enabling, starting X at boot

Configuring input devices

Installing X utilities like xrandr, arandr

Window manager agnostic - supports many WMs

This allows playbook authors to declaratively configure the full X system, GPU drivers and window managers while reusing common tasks. Vars allow flexibility per target based on hardware.

The role provides an Ansible-driven approach to repeatably deploy visual environments at scale. Its structure, defaults and parameters promote modularity, extensibility and deployability.

---

# variables

Here are some key details about how the X role sets variables and uses them:

Variables are defined in roles/x/vars/main.yml and can be overridden per host

Common variables include:

packages - Names of packages to install

video_driver - GPU driver like nvidia or intel

xorg_config - Settings for xorg.conf template

Default variables are set in roles/x/defaults/main.yml

Host-specific variables can be set in host_vars/*.yml

Templates render configuration files using Jinja templating

Templates reference variables like {{ packages.xorg }}
Tasks use the variables:

Install correct packages based on video_driver

Generate xorg.conf from template using variables

Enable correct GPU kernel modules

Includes allow splitting logic across multiple task files

Tags group tasks so they can be run selectively

Conditionals like when: allow conditional task execution

So in summary, variables:

Define common/per-host configuration

Are accessed via templates that generate config files

Are used within tasks to conditionalize operations

This allows declarative, repeatable X provisioning across different hardware using a single role definition.