# desktop

The "desktop" role in the Ansible automation framework is responsible for configuring the desktop environment, window manager, and general applications on Linux workstations. It performs several key tasks and configurations:

1. **Installing Package Groups**: Installs various package groups such as desktop, browser, media, etc.

2. **Creating Configuration Directories**: Creates directories for storing configuration files for applications.

3. **Generating Config Files**: Generates configuration files from templates for applications like dunst, picom, etc.

4. **Configuring DM/Login**: Configures the display manager/login by setting .dmrc and enabling automatic login.

5. **Importing Tasks**: Imports tasks to configure additional components like input-remapper, menu, barrier for multi-machine desktop use.

6. **Setting Autostart Applications**: Configures autostart applications using xdg.

7. **Configuring Thunar File Actions**: Configures file actions for the Thunar file manager.

8. **Updating Desktop Database**: Updates the desktop database for applications.

The role uses several variables, including package group lists defined elsewhere, user information like home, name, group from common_vars.yml, and configurations for the window manager and Barrier.

Overall, the "desktop" role provides functionality to fully configure a desktop environment, including installing packages, configuring the window manager, setting application autostart, shortcuts, and other aspects of a customized desktop experience. It aims to set up a complete, ready-to-use desktop environment in an automated and reusable way.


# i3

The i3 role in Ansible focuses on installing and setting up the i3 window manager. It follows the standard role structure with key files and directories:

- README.md: Documentation on the role's purpose and usage.
- defaults/main.yml: Default variable values for the role.
- handlers/main.yml: Handlers for the role's tasks.
- tasks/main.yml: Main tasks file, including imports for additional tasks files.
- templates/: Directory for template files used in configuration.
- vars/main.yml: Role-specific variables.

Specific tasks performed by the i3 role include:

1. Installing the i3 package.
2. Generating and configuring i3 configuration files from templates.
3. Setting up i3 autostart applications.
4. Configuring i3 window bindings and workspaces.
5. Managing the i3 service, including enabling, starting, and restarting it.
6. Importing additional tasks files for configuring components like i3bar, i3blocks, etc.

Overall, the i3 role provides a comprehensive configuration for installing, setting up, and managing i3 as the window manager through Ansible in a repeatable manner. It focuses solely on i3 tasks while adhering to best practices for role structure and documentation.


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
