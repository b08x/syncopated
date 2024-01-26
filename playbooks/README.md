# playbooks

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