<h1 align="center">
  <br>
  <img height="300" src="https://github.com/b08x/syncopatedIaC/blob/development/docs/images/pixelcrow03.png?raw=true"> <br>
    SyncopatedIac
<br>
</h1>

# SyncopatedIaC: An Audio-Centric Linux Distribution Framework

This project explores Infrastructure as Code (IaC) principles to streamline Linux desktop configuration for audio production.  It aims to demonstrate best practices, promote customization, and facilitate a collaborative, community-driven approach to overcoming workflow challenges in the open-source audio engineering landscape.

While not a production-ready solution in itself, SyncopatedIaC provides a robust foundation and modular building blocks for crafting tailored Linux audio distributions. It prioritizes professional audio software, real-time optimizations, and streamlined workflows.

## Key Concepts

- **Configuration as Code:** Ansible playbooks define the precise settings and software required for your ideal audio environment. This ensures repeatability, reduces manual intervention, and makes sharing setups across a studio or team seamless.
- **Customization and Experimentation:** yadm manages version control for your personal dotfiles (terminal preferences, editor configs, etc.). Tweak, test, and revert with ease, while effortlessly replicating your perfected environment on new workstations.
- **Focus on Audio:** Automate the installation and configuration of specialized DAWs, plugins, virtual instruments, and essential development tools. Optimize system settings for low-latency audio (JACK, PulseAudio, ALSA) and reliably manage hardware audio interfaces and MIDI devices.
- **Community-Driven Collaboration:** We invite contributions and insights from audio professionals and Linux enthusiasts. Together, we can expand SyncopatedIaC's capabilities, refine practices, and support diverse audio production setups.

## Framework Potential

- **Automation for Streamlined Workflows:** Write custom scripts or leverage existing tools to automate repetitive audio tasks. Examples include batch processing files, backing up audio projects, syncing files between machines, and deploying processing to more powerful servers.
- **Generative Audio and Data Exploration:** Develop scripts to analyze audio features and use this data to drive generative audio processes or create unique visualizations. Programmatically generate MIDI control data and parameter automation curves for intricate sounds within synths.
- **Version Control for Audio Projects:** Track changes and experiment with audio projects using Git. Revert to previous versions, collaborate on sound design, and manage shared plugin/effect configurations.
- **Specialized Audio Appliances:** Create purpose-built, embedded Linux audio solutions. Think dedicated live mixing systems, network-based audio appliances, or custom recording devices.

## Integration of Ansible and yadm

### Single Workstation

1. **Pre-task: Pull Dotfiles with Ansible:** A playbook starts by fetching your latest dotfiles (managed by yadm) to ensure core customizations are in place before system-wide changes begin.
2. **System Changes with Ansible:** Ansible proceeds with package installation, system service configuration, applying system-wide tweaks, and potentially deploying application-specific settings.
3. **Post-task: Commit and Push with yadm:** A final yadm task checks for system-level changes impacting dotfiles. If necessary, it commits and pushes these changes to your repository.

### Scaling with Multiple Hosts

Adapt the integration for different scenarios. In studios with similar setups, run this process on each machine. For centralized dotfile management, Ansible can execute a "yadm bootstrap" command on each remote host. Carefully consider which dotfiles should be standardized across workstations and which should remain unique to individual users.


## Invitation to Collaborate

We actively seek contributions and insights from experienced Linux audio professionals and developers.  Together, we can enhance this framework's capabilities, support diverse audio use cases, and drive innovation in the realm of open-source audio solutions.

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


# demo

[![asciicast](https://asciinema.org/a/622463.svg)](https://asciinema.org/a/622463)

# testing

```bash

ansible-inventory-grapher -i inventory.ini all -o "{}.dot" -a \
  "rankdir=LR; splines=ortho; ranksep=2;\
  node [ width=5 style=filled fillcolor=orange background=black ];\
  edge [ dir=back arrowtail=empty style="dashed" ];\
  bgcolor="darkgray";"

```


#TODO:

- [ ] add Pro Tools
