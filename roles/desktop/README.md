# desktop

# What are the tasks and configurations performed by the "desktop" role?
The /syncopatedIaC/roles/desktop/tasks/main.yml file defines the tasks for the "desktop" role. The main tasks and configurations performed are:

Installing various package groups like desktop, browser, media, etc.
Creating configuration directories
Generating config files from templates for configs like dunst, picom, etc.
Configuring the DM/Login by setting .dmrc
Importing tasks to configure things like input-remapper, menu, barrier
Setting xdg autostart applications
Configuring Thunar file actions
Updating the desktop database
It also imports the barrier.yml file to configure Barrier for multi-machine desktop use.

# What variables are used by the "desktop" role and where are they declared?
The main variables used are:

packages.* - Package group lists defined elsewhere
user.* - User info like home, name, group from common_vars.yml
desktop.wm - Selected window manager
desktop.barrier - Barrier configuration
Variables are also defined in roles/desktop/defaults/main.yml.

# What functionality does the "desktop" role provide?
The "desktop" role provides functionality to fully configure a desktop environment including installing packages, configuring the window manager, setting application autostart, shortcuts, configs and other aspects of a customized desktop experience.

It works to set up a complete out of box ready to use desktop on various OS's in an automated and reusable way.

---

The desktop role handlestasks related to configuring the desktop environment, window manager and general applications.

Some key aspects it manages:

Structure is standard with tasks, defaults, vars folders.

Installs base desktop packages like gnome, kde, xfce based on {{desktop.wm}} value.

Installs browser, media, development dependent packages.

Creates configuration directories for apps like dunst, picom, sxhkd etc.

Generates config files from templates - i3, dunstrc, picom etc.

Manages DM/Login - sets .dmrc, enables automatic login.

Configures WM - i3, sway related tasks are imported conditionally.

Handles input methods - input-remapper tasks.

Configures menu, thunar files, bindings - menu.yml, sxhkd.yml

Sets xdg autostart apps, dunst, updates desktop db.

Barrier role for multi-machine desktop - configs, services.

Key goal is a fully configured and customized desktop environment including window manager, applications and preferences. Reusable across different *buntu/Arch systems.

Main files involved are tasks/main.yml, calls to other subdomain task files, and Jinja template config file generation.