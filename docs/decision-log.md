## Bootstrapping

1. Terraform creates Lambda, Github Actions deploy lambda function code.
- Terraform creates the Lambda function, IAM configuration, environment variables, and invocation permission. 
- GitHub Actions owns function code and packages pinned runtime dependencies into one deployment artifact. 
- Terraform ignores code changes. 
- Layers are not used because dependencies are specific to one small function.

2. Terraform create secret in Secrets Manager, manually add value
- Secrets are created by Terraform
- Secret values are manually added

3. Terraform initialize ECS cluster, service and task, Github Actions manage consequent deployments
- ECS environment variables and secrets like DB creds are referenced within Terraform
- Github Actions build and tag new image and update the task definition by downloading it from AWS first, preserving the env vars and secret references 

## Decision

1. Secrets Manager: RDS credentials, Discord webhook URL, Everything in 1 secret
- Reason: Cut cost
- Split secret in production to separate access control across teams.

