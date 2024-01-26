

# something something configuration

```yaml
- hosts: localhost
  become: True
  gather_subset:
    - hardware
    - network
  vars:
    desktop:
      wm: 'i3'
      shell: 'zsh'
      dm: greetd
      terminal: 'terminator'
      audio: 'jack'
      ruby_version: 3.0.0
      python_version: 3.11.1
    cleanup: True
environment:
    PKG_CONFIG_PATH: "/usr/share/pkgconfig:/usr/lib/pkgconfig:/usr/local/lib/pkgconfig"
    ZSH: "/usr/share/oh-my-zsh"
    DISPLAY: ":0"

pre_tasks:

roles:

  - role: desktop
    tags: ['desktop']
```
