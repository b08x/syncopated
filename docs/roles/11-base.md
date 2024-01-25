# the base role


The main tasks performed by the base role include:

- Ensuring root directories exist that will be used by other roles.
    
- Configuring environment variables and default paths according to the XDG Base Directory spec. This includes things like $HOME/.config, $XDG_CONFIG_HOME, etc.
    
- Configuring SSH daemon settings like PermitRootLogin.
    
- Installing SSH keys and known_hosts files.
    
- Configuring passwordless sudo and Sudoers rules for the automation user.
    
- Managing package repositories - adds required repos, imports keys.
    
- Updating all packages to latest versions.
    
- Installing basic utility packages like vim, traceroute, etc.
    
- Configuring the package manager config - apt sources.list, pacman.conf, etc.
    
- Managing the Linux kernel, building initramfs images.
    
- Configuring the bootloader (GRUB).
    
- Installing basic services like autofs for automounting.
    
- Deploying common scripts and utilities to all hosts.
    

So in summary, it handles fundamental OS configuration and enables basic functionality that is reused across all other roles for a standardized environment. This establishes a common baseline.

Key files involved are roles/base/tasks/main.yml and the included task files for each subdomain.