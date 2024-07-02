<img width=500 height=400 src="https://github.com/b08x/syncopatedCaC/blob/development/assets/workspace07.jpeg?raw=true"><h2>Syncopated OS</h2>

An exercise in using Ansible for Workstation Provisioning & Configuration Management


## Objectives

-   **Organize Environments:** Centralize system and user configuration (dotfiles) for clarity and maintainability.

-   **Reproducible Setups:** Effortlessly replicate a preferred setup on new machines or restore it after changes.

-   **Efficiency in Workflow:** Automate tasks within audio and software development workflows.


## Core Components

  * **Ansible (Automation Engine):**  Manages system-level configurations including:
    * Audio:
        - Installation and updates of DAWs, plugins, virtual instruments, and development tools.
        - Low-latency system performance optimization (kernel, JACK, PulseAudio, ALSA).
        - Configuration of audio interfaces, MIDI controllers, and external hardware.
        - Setup and synchronization of networked audio environments (if applicable).

    * Development:
      - Installation of IDEs, programming libraries (Ruby, Python, etc.),
      - Configuration of virtualization/containerization platforms, package managers, and essential tools.
      - Integration with network shares, remote systems, and collaboration platforms.



## Use Cases

### Media Production

* **Workflow Optimization:** Automate common media production tasks:
    * Batch processing audio files for format conversion, normalization, and applying effects.
    * Streamline project backups, file syncing, and remote transfers for seamless collaboration.
    * Script the deployment of audio processing jobs to distributed render farms.

### Data-Driven Creativity

* **Explore the intersection of programming and audio:**
    * Analyze audio files to extract key, tempo, or rhythmic patterns to drive visual aids, automatic adjustments, or generative music elements.
    * Build custom audio synthesis and processing tools for unique sound design elements.
    * Control MIDI instruments, effects, or visualizers with analyzed audio data for dynamic performances or installations.

## Collaboration

Contributions from audio professionals, software developers, and Linux enthusiasts are welcome. Let's collaborate to build a versatile solution for managing Linux audio and development environments!

# demo playbook run

[![asciicast](https://asciinema.org/a/654626.svg)](https://asciinema.org/a/654626)

* * *

#### Ok

## Directory Index

| Path                      | Content                                     |
| :------------------------ | :------------------------------------------ |
| [assets](assets/)           | media files                               |
| [bin](bin/)                | utiliy scripts                                          |
| [group_vars](group_vars/) | Variables for Host Groups                   |
| [host_vars](host_vars/)   | Variables for Hosts                         |
| [playbooks](playbooks/)   | Playbooks                                   |
| [plugins](plugins/)       | Plugins and Modules                         |
| [roles](roles/)           | Roles                                       |
| [vars](vars/)             | Variables to include in playbooks and tasks |
| ansible.cfg               | Ansible configuration file                  |
| inventory.ini             | Host inventory                              |


## Commonly Used Options

\--tags: Specify which tasks to run (e.g., network, desktop).

\--limit: Target specific groups or hosts (e.g., soundbot, workstation).

\--skip-tags: Exclude specific tasks.

\-e: Extra variables passed to the playbook (e.g., update_mirrors=true, distribution=Archlinux).

\--start-at-task: Specify the starting task within the playbook.

### Using Tags

```bash
ansible-playbook -i inventory.ini playbooks/full.yml --tags $TAGS --limit $HOSTNAME
```

For example

-   The `audio` tag is used to install and configure audio packages on a system.
-   When the `audio` tag is used, Ansible will run the following tasks:
    -   The `alsa` role is used to install and configure the ALSA sound system.
    -   The `pipewire` role is used to install and configure the PipeWire audio server.
    -   The `jack` role is used to install and configure the JACK audio connection kit.
    -   The `pulseaudio` role is used to install and configure the PulseAudio sound server.

# testing

```bash
ansible-inventory-grapher -i inventory.ini all -o "{}.dot" -a \
  "rankdir=LR; splines=ortho; ranksep=2;\
  node [ width=5 style=filled fillcolor=orange background=black ];\
  edge [ dir=back arrowtail=empty style="dashed" ];\
  bgcolor="darkgray";"
```


# installing

```shell
wget -O bootstrap.sh https://raw.githubusercontent.com/b08x/SyncopatedOS/development/bootstrap.sh && \
chmod +x bootstrap.sh && \
./bootstrap.sh
```
