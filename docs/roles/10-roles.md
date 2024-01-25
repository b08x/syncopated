# roles

The roles directory in Ansible contains different roles that can be included in a playbook to configure certain aspects or components of a system. Each role is self-contained and focuses on a specific task or domain.

The structure within each role directory is generally consistent and includes:

- README.md - Documents what the role does and how to use it.
    
- defaults/ - Default variable values.
    
- files/ - Static files used by the role.
    
- handlers/ - Handler definitions.
    
- templates/ - Template files rendered by the role.
    
- tasks/ - Main.yml containing the role's tasks.
    
- vars/ - Variables passed to the role.
    
- tests/ - Role tests.
    
- meta/ - Role dependencies.
    

Some examples roles provided are:

- alsa/ - Configure sound card and ALSA.
    
- i3/ - Install and configure i3 window manager.
    
- zsh/ - Configure Zsh shell.
    
- nas/ - Setup NFS shares for a NAS role.
    
- bash/ - Tasks related to Bash shell configuration.
    

Each role has a uniform structure and documention in the README file. This makes the roles reusable and easy to understand for playbook authors applying them. The roles provide modularization and logical grouping of related tasks into discrete units that can be mixed and matched across playbooks as needed.
