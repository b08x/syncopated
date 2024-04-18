<h1 align="center">
  <br>
  <img height="300" src="https://github.com/b08x/syncopatedIaC/blob/development/docs/images/pixelcrow03.png?raw=true"> <br>
    SyncopatedCaC
<br>
</h1>

**SyncopatedCaC: Configuration as Code for Linux Audio Workstations**

This project demonstrates the power of Configuration as Code (CaC) to manage and streamline Linux workstation setups for audio production. It provides a modular foundation for customizing your perfect audio environment, promoting a collaborative approach to Linux audio configuration.

**Key Concepts & Tools**

* **Configuration as Code (CaC):**  Ansible playbooks are the core of this project, ensuring your audio workstation's software, settings, and optimizations are defined in maintainable, shareable code.
* **Customization:** yadm is used for managing personal configuration files (dotfiles), fostering experimentation and easy replication of your ideal setup across machines.
* **Audio Focus:** Installation and configuration of DAWs, plugins, instruments, audio interfaces, and development tools are streamlined. System settings are tuned for low-latency (JACK, PulseAudio, ALSA).
* **Community Collaboration:** Contributions from audio professionals and Linux enthusiasts will expand SyncopatedIaC and support diverse setups.

**Framework Potential**

SyncopatedIaC's CaC approach enables unique capabilities:

* **Workflow Automation:** Improve efficiency with scripts for tasks like batch processing, backups, and syncing.
* **Generative Audio & Data Exploration:** Leverage CaC to analyze audio, driving generative processes, visualizations, or MIDI control.
* **Versioned Audio Projects:**  Track changes, collaborate, and manage audio projects effectively with Git.
* **Specialized Audio Appliances:** Build custom embedded Linux audio solutions using CaC principles.

**Scaling with Multiple Workstations**

* **Consistent Workstations:** Run Ansible playbooks for a standardized setup across a studio.
* **Centralized Dotfile Management:**  Use Ansible to manage dotfile distribution, ensuring a baseline experience while allowing individual customization where needed.

**Invitation to Collaborate**

We welcome contributions and insights to drive innovation in the open-source audio world. Share your CaC playbooks, scripts, and audio-specific Linux expertise!

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
