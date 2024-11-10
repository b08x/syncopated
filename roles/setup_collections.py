#!/usr/bin/env python3
import os
import shutil
import yaml

# Define the collections and their roles
COLLECTIONS = {
    'system_core': {
        'name': 'system_core',
        'description': 'Core system configuration roles',
        'roles': ['base', 'user', 'sudoers', 'xdg', 'tuning', 'distro']
    },
    'desktop_environment': {
        'name': 'desktop_environment',
        'description': 'Desktop environment and window manager roles',
        'roles': ['gnome', 'i3', 'x11', 'rofi', 'sxhkd', 'theme']
    },
    'audio_production': {
        'name': 'audio_production',
        'description': 'Audio system and DAW configuration roles',
        'roles': ['alsa', 'pulseaudio', 'pipewire', 'jackd', 'sonic-pi', 'daw', 'deadbeef']
    },
    'development_tools': {
        'name': 'development_tools',
        'description': 'Development environment setup roles',
        'roles': ['docker', 'vscode', 'ruby', 'pulsar', 'ollama']
    },
    'system_services': {
        'name': 'system_services',
        'description': 'Network and virtualization service roles',
        'roles': ['nginx', 'libvirt', 'networking', 'barrier', 'iso']
    },
    'media_tools': {
        'name': 'media_tools',
        'description': 'Media creation and system interaction roles',
        'roles': ['obs-studio', 'terminal', 'applications', 'input-remapper']
    },
    'storage': {
        'name': 'storage',
        'description': 'Storage management roles',
        'roles': ['nas']
    },
    'shell_environment': {
        'name': 'shell_environment',
        'description': 'Shell and terminal environment configuration roles',
        'roles': ['shell', 'homepage']
    }
}

def create_galaxy_yaml(collection_path, collection_info):
    """Create galaxy.yml file for a collection"""
    galaxy_config = {
        'namespace': 'b08x',  # Replace with your namespace
        'name': collection_info['name'],
        'version': '1.0.0',
        'readme': 'README.md',
        'authors': ['Robert Pannick <rwpannick@gmail.com>'],  # Replace with your info
        'description': collection_info['description'],
        'license': ['MIT'],
        'tags': [collection_info['name'].replace('_', ' ')],
        'dependencies': {},
        'repository': 'https://github.com/b08x/ansible-collections',  # Replace with your repo
    }
    
    with open(os.path.join(collection_path, 'galaxy.yml'), 'w') as f:
        yaml.dump(galaxy_config, f, default_flow_style=False)

def create_readme(collection_path, collection_info):
    """Create README.md file for a collection"""
    readme_content = f"""# {collection_info['name'].replace('_', ' ').title()}

{collection_info['description']}

## Roles

The following roles are included in this collection:

{chr(10).join(['- ' + role for role in collection_info['roles']])}

## Usage

Install this collection using:

```bash
ansible-galaxy collection install custom.{collection_info['name']}
```

## Requirements

- Ansible 2.9 or later

## License

MIT

## Author

Your Name
"""
    with open(os.path.join(collection_path, 'README.md'), 'w') as f:
        f.write(readme_content)

def setup_collection_structure():
    """Set up the basic collection structure"""
    # Create collections directory
    os.makedirs('collections', exist_ok=True)
    
    # Process each collection
    for collection_name, collection_info in COLLECTIONS.items():
        # Create collection directory structure
        collection_path = os.path.join('collections', collection_name)
        os.makedirs(collection_path, exist_ok=True)
        os.makedirs(os.path.join(collection_path, 'roles'), exist_ok=True)
        os.makedirs(os.path.join(collection_path, 'docs'), exist_ok=True)
        os.makedirs(os.path.join(collection_path, 'plugins'), exist_ok=True)
        
        # Create galaxy.yml
        create_galaxy_yaml(collection_path, collection_info)
        
        # Create README.md
        create_readme(collection_path, collection_info)
        
        # Create docs/README.md
        with open(os.path.join(collection_path, 'docs', 'README.md'), 'w') as f:
            f.write(f"# {collection_name.replace('_', ' ').title()} Documentation\n\n")
            f.write("Add detailed documentation for each role here.\n")

def move_roles():
    """Move roles to their respective collections"""
    for collection_name, collection_info in COLLECTIONS.items():
        collection_roles_path = os.path.join('collections', collection_name, 'roles')
        for role in collection_info['roles']:
            src_path = role
            dst_path = os.path.join(collection_roles_path, role)
            if os.path.exists(src_path):
                if os.path.exists(dst_path):
                    shutil.rmtree(dst_path)
                shutil.copytree(src_path, dst_path)
                print(f"Moved {role} to {collection_name} collection")
            else:
                print(f"Warning: Role {role} not found in source directory")

def main():
    """Main function to set up collections"""
    print("Setting up collection structure...")
    setup_collection_structure()
    
    print("\nMoving roles to collections...")
    move_roles()
    
    print("\nCollection setup complete!")
    print("\nNext steps:")
    print("1. Review and update the galaxy.yml files with your information")
    print("2. Update the README.md files with specific usage instructions")
    print("3. Add any collection-specific documentation to the docs directory")
    print("4. Test the collections")
    print("5. Build and publish the collections using ansible-galaxy")

if __name__ == "__main__":
    main()