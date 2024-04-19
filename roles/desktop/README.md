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
