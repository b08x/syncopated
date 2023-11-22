base
=========

Tasks that apply any host in the environment,

|  tasks                           |  tags                                                   |
|:--------------------------------|:---------------------------------------------------------------|
| Starting base tasks | base, workstation |
| Ensure root directories exist | base, workstation |
| Placeholder for /etc/environment | base, env, profile, workstation |
| Adjust /etc/profile | base, env, profile, workstation |
| Set .aliases and .profile | base, env, profile, workstation |
| Set XDG env vars | base, env, profile, workstation, xdg |
| Set xdg user-dirs defaults | base, profile, workstation, xdg |
| Enable xdg-user-dirs-update service | base, profile, workstation, xdg |
| Remove existing user-dirs.dirs | base, profile, workstation, xdg |
| Run xdg-user-dirs-update | base, profile, workstation, xdg |
| install sshd config | base, sshd, workstation |
| restart sshd | base, sshd, workstation |
| Disable requiretty for user so automation can run without interruption | base, sudoers, workstation |
| Ensure /etc/sudoers.d exists | base, sudoers, workstation |
| Set NOPASSWD for user in sudoers | base, sudoers, workstation |
| Set NOPASSWD for user in polkit | base, sudoers, workstation |
| Set NOPASSWD for user in polkit | base, sudoers, workstation |
| Symlink /etc/os-release to /etc/system-release | base, packages, repo, workstation |
| Import syncopated repo key | base, packages, repo, workstation |
| Import archaudio repo key | base, packages, repo, workstation |
| Set pacman.conf config | base, packages, pacman, repo, workstation |
| Update cache | base, packages, repo, workstation |
| Install utility packages | base, packages, repo, workstation |
| Set makepkg to use aria2 | base, packages, repo, workstation |
| Check if paru installed | base, packages, repo, workstation |
| Install paru | base, packages, repo, workstation |
| Adjust paru config | base, packages, repo, workstation |
| Check if mirrors have been updated within the past 24h | base, mirrors, packages, repo, workstation |
| Print mirror file status | base, mirrors, packages, repo, workstation |
| Update mirrors | base, mirrors, packages, repo, workstation |
| Update cache | base, mirrors, packages, repo, workstation |
| Symlink /etc/os-release to /etc/system-release | base, packages, repo, workstation |
| Disable selinux | base, packages, repo, workstation |
| Reboot host if selinux status changes | base, packages, repo, workstation |
| Wait for host to reboot | base, packages, repo, workstation |
| Import ELRepo GPG key | base, packages, repo, workstation |
| Install ELRepo repository | base, packages, repo, workstation |
| Install postgresql repository | base, packages, repo, workstation |
| Refresh DNF repositories | base, packages, repo, workstation |
| Install yum-utils and additional repositories | base, packages, repo, workstation |
| Install Utility Packages | base, packages, repo, workstation |
| set package_manager_install fact | always, base, packages, repo, workstation |
| set package_manager_uninstall fact | always, base, packages, repo, workstation |
| Install mlocate | base, packages, updatedb, workstation |
| Set directories to not be indexed | base, updatedb, workstation |
| Run updatedb | base, updatedb, workstation |
| Disable swap | base, workstation, zram |
| Install zram-generator | base, packages, workstation, zram |
| Install zram-generator.conf | base, workstation, zram |
| Install sysctl zram parameters | base, workstation, zram |
| Reload systemd daemon | base, workstation, zram |
| Set kernel cmdline params in grub | base, grub, workstation |
| Remake grub if changes were made | base, grub, workstation |
| Set autofs config folder | autofs, base, workstation |
| Set autofs config folder | autofs, base, workstation |
| install autofs | autofs, base, packages, workstation |
| install autofs | autofs, base, packages, workstation |
| Create mount directory folder if it doesn't already exist | autofs, base, workstation |
| Install autofs configs | autofs, base, workstation |
| enable autofs service | autofs, base, workstation |
| sync utility scripts | always, base, scripts, workstation |
