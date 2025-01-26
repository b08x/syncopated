# GNOME Role

This role installs and configures GNOME desktop environment with X11 support across different Linux distributions.

## Requirements

- Ansible 2.9 or later
- One of the supported distributions:
  - Debian
  - Ubuntu
  - Fedora
  - Arch Linux
- X11 role (automatically included as a dependency)

## Role Variables

Available variables are listed below, along with default values (see `defaults/main.yml`):

```yaml
# Package names are distribution-specific
gnome_packages:
  Debian:
    - gnome-shell
    - gnome-control-center
    # ... (see defaults/main.yml for full list)

# GNOME interface settings
gnome_settings:
  interface:
    clock_format: "24h"
    enable_animations: true
    # ... (see defaults/main.yml for full list)
  
  # Custom keybindings for window management and media keys
  keybindings:
    keybindings:  # Window manager keybindings
      switch-to-workspace-1: ["<Super>1"]
      switch-to-workspace-2: ["<Super>2"]
      switch-to-workspace-3: ["<Super>3"]
      switch-to-workspace-4: ["<Super>4"]
    media-keys:  # Media and system control keybindings
      volume-up: ["<Super>Up"]
      volume-down: ["<Super>Down"]
      play: ["<Super>p"]
      screenshot: ["<Super>Print"]

# Display Manager settings
gdm_settings:
  autologin_enabled: false
  wayland_enabled: false  # Force X11 session

# GNOME Shell extensions
gnome_extensions_enabled:
  - "user-theme@gnome-shell-extensions.gcampax.github.com"
  # ... (see defaults/main.yml for full list)
```

## Dependencies

- x11 role (included in this collection)

## Example Playbook

```yaml
- hosts: workstations
  roles:
    - role: gnome
      vars:
        gnome_settings:
          interface:
            clock_format: "12h"
            gtk_theme: "Adwaita-dark"
        gdm_settings:
          wayland_enabled: false
```

## Capturing Current Settings

This role includes a Python script that can capture your current GNOME settings and automatically configure the role to use them. To use it:

1. Ensure you have Python 3 and PyYAML installed:
   ```bash
   pip3 install pyyaml
   ```

2. Run the capture script from within the role directory:
   ```bash
   ./files/capture_settings.py
   ```

The script will:
- Detect your current distribution
- Capture all relevant GNOME settings via dconf
- List installed GNOME packages
- Save the settings directly to the role's vars/main.yml

After running the script, you can simply use the role in your playbook and it will apply your captured settings:
```yaml
- hosts: workstations
  roles:
    - gnome
```

## Customization

### Desktop Environment Settings

The role provides extensive customization options for various aspects of the GNOME desktop environment:

- Interface appearance (themes, fonts, icons)
- Privacy settings
- Power management
- Desktop behavior
- Session management
- Sound settings
- Custom keybindings (window management and media keys)

### Keybindings

The role supports configuring both window management and media key bindings:

- Window Management Keybindings:
  - Workspace switching
  - Window control (maximize, minimize, etc.)
  - Window movement and resizing

- Media Key Bindings:
  - Volume control
  - Media playback
  - Screen capture
  - Custom system commands

Keybindings can be configured in the standard GNOME format using modifiers like:
- `<Super>` (Windows/Command key)
- `<Alt>`
- `<Ctrl>`
- `<Shift>`

### Display Manager

- Configures GDM (GNOME Display Manager)
- Supports both gdm and gdm3 (distribution-dependent)
- Can force X11 session by disabling Wayland

### Distribution Support

The role automatically detects the distribution and uses the appropriate:
- Package manager (apt, dnf, pacman)
- Package names
- Service names (gdm vs gdm3)

## Tags

- `packages`: Package installation tasks
- `gnome`: GNOME configuration tasks
- `settings`: Desktop environment settings
- `services`: Service management tasks
- `x11`: X11-specific configuration

## License

MIT

## Author

Robert Pannick
