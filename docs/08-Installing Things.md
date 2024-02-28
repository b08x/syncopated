# Installing things


It's what we live for.

```yaml
# simply just defining the variable will install the thing
# it will call the task list
# if desired more variables can defined within the tasks
# f.e:
# vscode:
#   packages:
#     example_package: 1.0

vscode:
pulsar:

```


```yaml
- import_tasks:
    file: dev/pulsar.yml
  when: pulsar is defined
  tags: ['pulsar']
```
