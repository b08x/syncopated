#!/usr/bin/env python

# Define variables
group_vars_all = {"tuned": {"profile": "powersave"}}
host_vars_example_host = {"tuned": {"profile": "performance"}}

# Simulate variable precedence logic

# Check if tuned variable is defined in host_vars_example_host
if "tuned" in host_vars_example_host:
    # Get the tuned profile from host_vars_example_host
    tuned_profile = host_vars_example_host["tuned"]["profile"]
else:
    # If not defined in host_vars_example_host, check group_vars_all
    if "tuned" in group_vars_all:
        tuned_profile = group_vars_all["tuned"]["profile"]
    else:
        # If not defined anywhere, set a default
        tuned_profile = "default"

# Print the final tuned profile
print(f"Final tuned profile: {tuned_profile}")
