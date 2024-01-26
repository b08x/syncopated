# applications

The main tasks performed by the applications role include:

Installing various audio/creative applications using package definitions

This is done through the AUR helper (paru) by name lists.

Ensuring configuration directories exist for applications

It creates dirs defined in defaults like ~/.sonic-pi/config

Conditionally importing additional application role files

These configure specific apps like Reaper, VSCode, etc.

Downloading/building apps from URLs or git repos

For apps not available as packages

Some key files involved:

roles/applications/tasks/main.yml

roles/applications/vars/main.yml

roles/applications/defaults/main.yml

roles/applications/*.yml (app roles)

So in summary, it:

Installs available apps as packages

Configures app-specific directories

Optionally includes roles for custom apps

Downloads/builds other apps from sources

This provides an automated, modular approach to provisioning a workstation with desired creative/audio applications based on variables.

---

# The applications role provides functionality to install and configure common multimedia and creative applications.

Specifically, it:

Installs packages grouped by type (ambisonics, analysis, editors etc)

Reads package names from the vars/packages.yml file

Ensures configuration directories exist for apps

Imports additional tasks files to fully configure specific apps

media/mixxx.yml

ide/pulsar.yml

analysis/vamp.yml

Supports conditional inclusion based on variables

Only includes pulsar if app.install.pulsar is true
Groups tasks with tags for selective execution

["media", "deadbeef"]

["vamp"]

So in summary, it:

Installs common creative/media application packages

Configures app-specific directories

Imports roles that fully configure particular apps

Supports conditional and selective configuration

This provides an infrastructure as code approach to reproducibly deploy a standardized creative application stack.

The role establishes the base installation while retaining flexibility.