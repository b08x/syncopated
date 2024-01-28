# playbooks

The playbooks directory contains Ansible playbook files that orchestrate configurations defined in roles across multiple systems.

Some key details:

Location: /syncopatedIaC/playbooks

Main playbook: full.yml applies all roles/tasks

Other playbooks target specific workflows

Variables are imported from /vars

Roles are defined and applied

Pre_tasks block setsplaybook-specific vars

Tags allow running subsets of tasks

Includes pull in additional yaml files

When conditionals control role imports

Registered vars capture command outputs

Templates, files fetch external content

Tasks rely on correctly ordered roles

So in summary, playbooks provide the overall orchestration logic:

Import required variables, files
Set overridable parameters
Include external task files
Conditionally apply roles -Define the order of operation
Register outputs
Produce an effective workflow
They combine modular roles aligned with best practices for reusable, parameterized infrastructure as code.






Here's how variables are set and used in the full playbook:

Variable files like packages.yml and theme.yml are imported, defining common values

Pre-task blocks set variables:

Set PATH, PKG_CONFIG_PATH, ZSH env vars

Register unique suffix timestamp

Check CPU arch & set architecture fact

Check for new install and define keyserver

Roles import additional vars files to specialize config

Templates reference variables to generate config files

Tasks use variables:

Install packages based on packages var

Set theme based on theme var

Copy ssh keys conditionally

roles/user sets home folders using user var

Includes allow splitting logic across multiple task files

Tags group related tasks

When conditionals run tasks selectively

register variables capture outputs

So in summary, variables defined in vars files and role defaults:

Are set/overwritten by playbook as needed
Are accessed by templates
Direct conditional task execution
Are used within tasks
This provides a repeatable, parameterized playbook flow using declarative infrastructure as code principles.