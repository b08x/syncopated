# distro

# What are the tasks and configurations performed by the "distro" role?
The distro role does not define any tasks itself. It conditionally imports the tasks from the Archlinux/main.yml file if the distribution is Archlinux or EndeavourOS. No other tasks are defined.

# What variables are used by the "distro" role and where are they declared?
The only variables defined for the distro role are:

distribution - OS distribution name defined elsewhere
admin_group - Default admin group defined in /syncopatedIaC/roles/distro/defaults/main.yml
repos - Lists of repos to enable defined in /syncopatedIaC/roles/distro/defaults/main.yml

# What functionality does the "distro" role provide?
The distro role provides a means to partition functionality specific to Linux distributions in a generic way.

It allows defining distribution-specific tasks, variables and handlers by importing them conditionally based on the distribution variable.

For Archlinux systems, it provides the functionality defined in the imported Archlinux/main.yml tasks file. But other distro tasks could also be added similarly.

So in summary, it provides a way to abstract out distribution-specific configuration and installation steps while keeping common roles and variables defined separately.