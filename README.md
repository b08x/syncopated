# Ansible Collection - b08x.syncopated

Documentation for the collection.



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
      autologin: False
      term: 'terminator'
      audio: 'jack'
      ruby_version: 3.0.0
      python_version: 3.11.1
    daw:
      apps:
        - 'reaper'
        - 'bitwig'
        - 'sonic-pi'
      plugins:
        - 'swh-lv2'
        - 'x42'
        - 'zita'
        - 'ambix'

    cleanup: True
    path:
      - "{{ lookup('env','HOME') }}/.local/bin"
  environment:
    PATH: "{{ ansible_env.PATH }}:/sbin:/bin:{{ path|join(':') }}"
    PKG_CONFIG_PATH: "/usr/share/pkgconfig:/usr/lib/pkgconfig:/usr/local/lib/pkgconfig"
    ZSH: "/usr/share/oh-my-zsh"
    DISPLAY: ":0"

pre_tasks:

roles:

  - role: desktop
    tags: ['desktop']



```
