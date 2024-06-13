# Purpose

This is the repository which I use to automate the management (where management means simple creation and deletion) of service principals across the current subscription I am signed into.

# Prerequisites

- The following shell should be used: `Bash`.
- The following tools should be installed: `AZ CLI`, `jq`.
- At least `Cloud Application Administrator` Microsoft Entra role.
- At least `User Access Administrator` Azure RBAC role over your subscription.

# Summary of usage

- Begin by logging in with `az login --use-device-code` and sign into the correct tenant and subscription.
- To create a service principal run the script in create mode with `./manage-spn -c -n <spn name>`
- To delete a service principal run the script in delete mode with `./manage-spn -d -n <spn name>`
