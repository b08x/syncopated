#!/usr/bin/env python3
import subprocess
import json
import yaml
import re
import platform
import os
from pathlib import Path

def run_command(command):
    """Run a shell command and return its output"""
    try:
        result = subprocess.run(command, shell=True, check=True,
                              capture_output=True, text=True)
        return result.stdout.strip()
    except subprocess.CalledProcessError as e:
        print(f"Error running command '{command}': {e}")
        return ""

def get_dconf_dump():
    """Get all dconf settings"""
    return run_command("dconf dump /")

def get_distribution():
    """Get Linux distribution name"""
    try:
        with open('/etc/os-release') as f:
            os_release = dict(line.strip().split('=', 1) for line in f if '=' in line)
            # Remove quotes if present
            return os_release.get('ID', '').strip('"').lower()
    except FileNotFoundError:
        return ''

def get_installed_packages():
    """Get installed GNOME packages based on distribution"""
    distro = get_distribution()
    if distro in ['debian', 'ubuntu', 'pop']:
        cmd = "dpkg -l | grep -i gnome | awk '{print $2}'"
    elif distro == 'fedora':
        cmd = "rpm -qa | grep -i gnome"
    elif distro in ['arch', 'manjaro']:
        cmd = "pacman -Qq | grep -i gnome"
    else:
        print(f"Unsupported distribution: {distro}")
        return []
    
    packages = run_command(cmd).split('\n')
    return [pkg for pkg in packages if pkg]

def parse_dconf_settings(dconf_dump):
    """Parse dconf dump output into structured format"""
    settings = {}
    current_section = None
    
    for line in dconf_dump.split('\n'):
        if line.startswith('['):
            # New section
            current_section = line.strip('[]')
            settings[current_section] = {}
        elif '=' in line and current_section:
            key, value = line.split('=', 1)
            key = key.strip()
            value = value.strip()
            
            # Convert value to appropriate type
            if value.lower() in ('true', 'false'):
                value = value.lower() == 'true'
            elif value.isdigit():
                value = int(value)
            else:
                # Strip quotes if present
                value = value.strip("'\"")
                
            settings[current_section][key] = value
    
    return settings

def map_to_role_vars(settings, packages):
    """Map parsed settings to role variables structure"""
    distro = get_distribution().capitalize()
    
    role_vars = {
        'gnome_packages': {
            distro: packages
        },
        'gnome_settings': {
            'interface': {},
            'privacy': {},
            'power': {},
            'desktop': {},
            'session': {},
            'sound': {}
        },
        'gdm_settings': {
            'wayland_enabled': False
        }
    }
    
    # Map interface settings
    if 'org/gnome/desktop/interface' in settings:
        interface = settings['org/gnome/desktop/interface']
        role_vars['gnome_settings']['interface'] = {
            'clock_format': interface.get('clock-format', '24h'),
            'enable_animations': interface.get('enable-animations', True),
            'show_battery_percentage': interface.get('show-battery-percentage', True),
            'cursor_size': interface.get('cursor-size', 24),
            'font_antialiasing': interface.get('font-antialiasing', 'rgba'),
            'font_hinting': interface.get('font-hinting', 'slight'),
            'gtk_theme': interface.get('gtk-theme', 'Adwaita'),
            'icon_theme': interface.get('icon-theme', 'Adwaita')
        }
    
    # Map privacy settings
    if 'org/gnome/desktop/privacy' in settings:
        privacy = settings['org/gnome/desktop/privacy']
        role_vars['gnome_settings']['privacy'] = {
            'remember_recent_files': privacy.get('remember-recent-files', True),
            'remove_old_trash_files': privacy.get('remove-old-trash-files', True),
            'remove_old_temp_files': privacy.get('remove-old-temp-files', True),
            'old_files_age': privacy.get('old-files-age', 30)
        }
    
    # Map power settings
    if 'org/gnome/settings-daemon/plugins/power' in settings:
        power = settings['org/gnome/settings-daemon/plugins/power']
        role_vars['gnome_settings']['power'] = {
            'sleep_inactive_ac_timeout': power.get('sleep-inactive-ac-timeout', 3600),
            'sleep_inactive_battery_timeout': power.get('sleep-inactive-battery-timeout', 1800),
            'power_button_action': power.get('power-button-action', 'suspend')
        }
    
    # Map desktop settings
    if 'org/gnome/nautilus/desktop' in settings:
        desktop = settings['org/gnome/nautilus/desktop']
        role_vars['gnome_settings']['desktop'] = {
            'show_home': desktop.get('home-icon-visible', True),
            'show_trash': desktop.get('trash-icon-visible', True),
            'show_mounted_volumes': desktop.get('volumes-visible', True)
        }
    
    # Map session settings
    if 'org/gnome/desktop/session' in settings:
        session = settings['org/gnome/desktop/session']
        role_vars['gnome_settings']['session'] = {
            'idle_delay': session.get('idle-delay', 300)
        }
    
    if 'org/gnome/desktop/screensaver' in settings:
        screensaver = settings['org/gnome/desktop/screensaver']
        if 'session' not in role_vars['gnome_settings']:
            role_vars['gnome_settings']['session'] = {}
        role_vars['gnome_settings']['session'].update({
            'lock_enabled': screensaver.get('lock-enabled', True),
            'lock_delay': screensaver.get('lock-delay', 0)
        })
    
    # Map sound settings
    if 'org/gnome/desktop/sound' in settings:
        sound = settings['org/gnome/desktop/sound']
        role_vars['gnome_settings']['sound'] = {
            'theme_enabled': sound.get('theme-enabled', True),
            'event_sounds': sound.get('event-sounds', True),
            'input_feedback_sounds': sound.get('input-feedback-sounds', True)
        }
    
    return role_vars

def main():
    # Get current settings
    dconf_dump = get_dconf_dump()
    packages = get_installed_packages()
    
    # Parse and map settings
    settings = parse_dconf_settings(dconf_dump)
    role_vars = map_to_role_vars(settings, packages)
    
    # Get the script's directory
    script_dir = Path(__file__).resolve().parent
    # Navigate to the role's vars directory
    vars_dir = script_dir.parent / 'vars'
    vars_dir.mkdir(exist_ok=True)
    
    # Save to YAML file
    output_file = vars_dir / 'main.yml'
    with open(output_file, 'w') as f:
        yaml.dump(role_vars, f, default_flow_style=False, sort_keys=False)
    
    print(f"Settings have been saved to {output_file}")
    print("\nThe settings are now available as role variables.")
    print("You can use the role in your playbook like this:")
    print("""
    - hosts: your_hosts
      roles:
        - gnome
    """)

if __name__ == "__main__":
    main()
