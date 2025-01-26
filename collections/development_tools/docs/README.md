# Development Tools Documentation

Add detailed documentation for each role here.

## IDE Role

The IDE role installs and configures popular development environments:

### Visual Studio Code

Installs Microsoft's VS Code editor with support for:
- Debian/Ubuntu systems (via official Microsoft repository)
- RedHat-based systems (via official Microsoft repository)
- Arch Linux (via community package)

### Pulsar Editor

Installs the Pulsar editor (community-driven Atom fork) using:
- AppImage distribution method (works across all Linux distributions)
- Includes desktop integration (application menu entry and icon)
- Installed in `/usr/local/bin` with proper permissions

### Configuration

The role uses variables defined in `vars/default.yml`:
- `vscode_extensions_enabled`: Toggle VSCode extensions installation
- `vscode_user_settings_enabled`: Toggle VSCode user settings configuration
- `pulsar_appimage_path`: Path for Pulsar AppImage installation
- `pulsar_desktop_entry_path`: Path for desktop entry file
- `pulsar_icon_path`: Path for application icon

### Requirements

- For Debian/Ubuntu: `apt-transport-https` and `curl` for repository management
- For RedHat: `dnf-plugins-core` for repository management
- For Arch Linux: Access to AUR for VSCode installation
- Internet access for downloading packages and Pulsar AppImage
