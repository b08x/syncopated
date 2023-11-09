# Ansible Collection - b08x.syncopated

Documentation for the collection.

Example playbook:

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
      applications:
        ide:
          - 'sonic-pi'
          - 'pulsar'
          - 'bipscript'
        audio:
          daw:
            - 'reaper'
            - 'bitwig'
          plugins:
            - 'swh-lv2'
            - 'x42'
            - 'zita'
            - 'ambix'
    path:
      - "{{ lookup('env','HOME') }}/.local/bin"
      # - /another/path/bin
    cleanup: True

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
