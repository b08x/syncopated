# desktop

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