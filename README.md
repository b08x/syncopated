<img align="left" width=460 height=400 src="https://github.com/b08x/syncopatedCaC/blob/development/files/workspace07.jpeg?raw=true"><h2>Configuration as Code for Linux Workstations</h2>

This project is an exercise codified configuration.

The project prioritizes three key objectives:

<p>Organization: To improve the maintainability and overall understanding of the workstation environment for administrators and users alike.</p>
<p>Reproducibility: Consistent and reliable configurations, enabling predictable and stable provisionings</p>
<p>Simplicity: While achieving the aforementioned goals, the project attempts to maintain a straight-forward approach.</p>
<br clear="left"/>

## Objectives

-   **Organize Environments:** Centralize system and user configuration (dotfiles) for clarity and maintainability.

-   **Reproducible Setups:** Effortlessly replicate a preferred setup on new machines or restore it after changes.

-   **Efficiency in Workflow:** Automate tasks within audio and software development workflows.

-   **Data-Driven Audio:**  Leverage programming for tasks like:

    * Audio file analysis (tempo, key, rhythmic patterns) to drive generative processes, visualizations, or effect settings.
    * Algorithmic sound synthesis, sample manipulation, or generative music creation.
    * Using analyzed data or external inputs to control sound generation and MIDI devices for dynamic results.

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


  - **yadm (Dotfile Management):** Version-controls and centralizes personal files for editors, terminals, desktop settings, and other preferences across software development and audio production.

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

### Versioned Projects

* **Seamless Collaboration:** Facilitate collaborative workflows in media productions using tools like Git:
    * Track changes in large audio projects alongside scripts, code, and other supporting assets.
    * Enable collaborative editing or score development with clear version history.

### Specialized Appliances

* **Custom Solutions:**  Employ CaC principles to design custom embedded Linux solutions or networked audio systems tailored for specific audio or development needs.

### Large Language Model Integration

* **Streamline LLM Workflows:**
    * Automate the setup and configuration of containerized LLM instances (Docker, Kubernetes).
    * Manage model versions, dependencies, and resource allocation across your workstations.
    * Optimize networking and storage configurations to streamline access and data transfer for LLM tasks.

## Collaboration

Contributions from audio professionals, software developers, and Linux enthusiasts are welcome. Let's collaborate to build a versatile solution for managing Linux audio and development environments!

# demo playbook run

[![asciicast](https://asciinema.org/a/654626.svg)](https://asciinema.org/a/654626)

* * *

#### Ok

## Directory Index

| Path                      | Content                                     |
| :------------------------ | :------------------------------------------ |
| [files](files/)           | Additional Files not included in roles      |
| [group_vars](group_vars/) | Variables for Host Groups                   |
| [host_vars](host_vars/)   | Variables for Hosts                         |
| [playbooks](playbooks/)   | Playbooks                                   |
| [plugins](plugins/)       | Plugins and Modules                         |
| [roles](roles/)           | Roles                                       |
| [scripts](scripts/)       | Various scripts to perform admin tasks      |
| [tasks](tasks/)           | Additional tasks not included in roles      |
| [templates](templates/)   | Additional templates not included in roles  |
| [vars](vars/)             | Variables to include in playbooks and tasks |
| ansible.cfg               | Ansible configuration file                  |
| inventory.ini             | Host inventory                              |

## Playbooks

| Name                                      | Description |
|:------------------------------------------|:------------|
| [workstation](playbooks/workstation.yml)  |             |
| [nas](playbooks/nas.yml)                  |             |
| [homepage](playbooks/homepage.yml)        |             |
| [database](playbooks/devops/database.yml) |             |
| [pihole](playbooks/devops/pihole.yml)     |             |
| [libvirt](playbooks/devops/libvirt.yml)   |             |
| [docker](playbooks/devops/docker.yml )    |             |
| [webhost](playbooks/devops/webhost.yml)   |             |
| [packager](playbooks/devops/packager.yml) |             |


## Roles


| Name                              | Description |
|:----------------------------------|:------------|
| [audio](roles/audio/)             |             |
| [base](roles/base/)               |             |
| [daw](roles/daw/)                 |             |
| [desktop](roles/desktop/)         |             |
| [development](roles/development/) |             |
| [dify](roles/dify/)               |             |
| [distro](roles/distro/)           |             |
| [docker](roles/docker/)           |             |
| [flowise](roles/flowise/)         |             |
| [libvirt](roles/libvirt/)         |             |
| [llm](roles/llm/)                 |             |
| [multimedia](roles/multimedia/)   |             |
| [nas](roles/nas/)                 |             |
| [network](roles/network/)         |             |
| [nginx](roles/nginx/)             |             |
| [obs-studio](roles/obs-studio/)   |             |
| [ruby](roles/ruby/)               |             |
| [shell](roles/shell/)             |             |
| [sillytavern](roles/sillytavern/) |             |
| [sonic-pi](roles/sonic-pi/)       |             |
| [user](roles/user)                |             |


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
