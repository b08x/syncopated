<h1 align="center">
  <br>
  <img height="300" src="https://github.com/b08x/syncopatedIaC/blob/development/docs/images/pixelcrow03.png?raw=true"> <br>
    SyncopatedCaC
<br>
</h1>

# SyncopatedCaC: Configuration as Code for Linux Workstations

This project explores the practical use of Configuration as Code (CaC) for managing and optimizing Linux workstations tailored for both audio production and software development.

The project focuses on organization, reproducibility, consistency and simplicity.

## Objectives and Aspirations

* **Organized Environments:** Centralize host system and personal configuration files (including dotfiles) to promote clarity across both development and audio production environments.

* **Reproducible Setups:** Effortlessly replicate a customized setup on new machines or restore it after changes, minimizing downtime across all work domains.

* **Efficiency in Workflow:** Automate tasks within audio and software development workflows to minimize manual intervention and streamline operations.

* **Data-Driven Audio:**  Leverage programming for tasks like:
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

* **yadm (Dotfile Management):** Version-controls and centralizes personal files for editors, terminals, desktop settings, and other preferences across software development and audio production.

## Additional Capabilities


### Media Production

* **Workflow Optimization:** Extend SyncopatedCaC with scripting automation for common media production tasks:
    * Batch processing audio files for format conversion, normalization, and applying effects.
    * Automating project backups, file syncing, and remote transfers to streamline collaboration.
    * Scripting deployment of audio processing jobs to distributed resources (e.g., render farms).

* **Data-Driven Creativity:**  Tap into the intersection of programming and audio for innovative possibilities:
    * Analyze audio files to extract key, tempo, or rhythmic patterns for visual aids, automatic adjustments, or generative music elements.
    * Develop custom audio synthesis and processing tools for unique sound design elements.
    * Control MIDI instruments, effects, or visualizers with analyzed audio data for dynamic performances or installations.

* **Versioned Projects:** Ensure seamless collaboration and asset tracking in media productions with tools like Git:
    * Track changes in large audio projects alongside scripts, code, and other supporting assets.
    * Facilitate collaborative editing or score development with clear version history.

* **Specialized Appliances:** Develop custom embedded Linux solutions or networked systems using CaC, tailored for specific development or audio needs.

### Large Language Model Integration

    * Automate the setup and configuration of containerized LLM instances (Docker, Kubernetes).
    * Manage model versions, dependencies, and resource allocation across your workstations.
    * Optimize networking and storage configurations to streamline access and data transfer for LLM tasks.



## Scaling Up:  Studio & Development Environments

* **Consistent Workstations:** Execute Ansible playbooks to guarantee configuration uniformity across all creative machines, bridging development and production domains.

* **Centralized Dotfile Management (Optional):** Ansible can distribute standardized dotfiles while allowing user-level refinement for individual workflows.


## Community Collaboration

We invite audio professionals, software developers, and Linux enthusiasts to contribute. Together, we can build a versatile solution that excels in managing Linux audio *and* development environments. Let's redefine the Linux desktop experience!


# demo

[![asciicast](https://asciinema.org/a/654626.svg)](https://asciinema.org/a/654626)

---

#### Ok


## Directory Index

| Path                      | Content                                     |     |
| :------------------------ | :------------------------------------------ | --- |
| [docs](docs/)             | An attempt at further Documentation         |     |
| [files](files/)           | Additional Files not included in roles      |     |
| [group_vars](group_vars/) | Variables for Host Groups                   |     |
| [host_vars](host_vars/)   | Variables for Hosts                         |     |
| [playbooks](playbooks/)   | Playbooks                                   |     |
| [plugins](plugins/)       | Plugins and Modules                         |     |
| [roles](roles/)           | Roles                                       |     |
| [scripts](scripts/)        | Various scripts to perform admin tasks     |     |
| [tasks](tasks/)           | Additional tasks not included in roles      |     |
| [templates](templates/)   | Additional templates not included in roles  |     |
| [vars](vars/)             | Variables to include in playbooks and tasks |     |
| ansible.cfg               | Ansible configuration file                  |     |
| inventory.ini             | Host inventory                              |     |

## Playbooks

* playbooks/full.yml: The main playbook, often run with various options.
* playbooks/homepage.yml: Playbook for setting up the homepage.
* playbooks/database.yml: Playbook for managing databases.
* playbooks/nas.yml: Playbook for setting up a NAS system.
* playbooks/pi.yml: Playbook for Raspberry Pi setups.
* playbooks/llmos.yml: Playbook for LLMOS tasks (unclear purpose).
* playbooks/llmops.yml: Playbook for LLMOPS tasks (likely typo of llmos).

## Commonly Used Options

--tags: Specify which tasks to run (e.g., network, desktop).

--limit: Target specific groups or hosts (e.g., soundbot, workstation).

--skip-tags: Exclude specific tasks.

-e: Extra variables passed to the playbook (e.g., update_mirrors=true, distribution=Archlinux).

--start-at-task: Specify the starting task within the playbook.

### Using Tags

```bash

ansible-playbook -i inventory.ini playbooks/full.yml --tags $TAGS --limit $HOSTNAME

```

For example

* The `audio` tag is used to install and configure audio packages on a system.
* When the `audio` tag is used, Ansible will run the following tasks:
  - The `alsa` role is used to install and configure the ALSA sound system.
  - The `pipewire` role is used to install and configure the PipeWire audio server.
  - The `jack` role is used to install and configure the JACK audio connection kit.
  - The `pulseaudio` role is used to install and configure the PulseAudio sound server.



# testing

```bash

ansible-inventory-grapher -i inventory.ini all -o "{}.dot" -a \
  "rankdir=LR; splines=ortho; ranksep=2;\
  node [ width=5 style=filled fillcolor=orange background=black ];\
  edge [ dir=back arrowtail=empty style="dashed" ];\
  bgcolor="darkgray";"

```
