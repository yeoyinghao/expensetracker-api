## Bootstrapping

1. Terraform creates Lambda, Github Actions deploy lambda function code.
- Layers are manually zipped and added afterwards and it does not change frequently to be in cicd

2. Terraform create secret in Secrets Manager, manually add value

## Decision

1. Secrets Manager: RDS credentials, Discord webhook URL, Everything in 1 secret
- Reason: Cut cost
- Split secret in production to separate access control across teams.

