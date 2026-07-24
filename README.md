<div align="center">

# expense-tracker

API for tracking expense.

</div>


## Project Overview

Spring Boot API that manages expenses. Run on Amazon ECS, Infrastructure managed by Terraform, CI/CD pipeline trigger on push with Github Actions.

## Project Features

- CI/CD: Automatically build docker image tagged by commit SHA and push to AWS ECR, updates AWS ECS task definition and points service to the correct version.
- Observability: CloudWatch Metric Alarm -> SNS -> Lambda -> Notification to Discord channel. CloudWatch Dashboard. CloudWatch Logs for ECS, RDS.
- Security: Store credentials in AWS Secret Manager, used by ECS and Lambda. Github Actions authenticated with OIDC without long living AWS access keys.
- Infrastructure as Code(IaC): Terraform manages AWS infrastructure with proper bootstrapping.


## Prerequisites

- AWS CLI
- Terraform 1.15+

## Setup

```sh
terraform init
terraform apply -var-file=terraform.tfvars
```
After `terraform apply` completed, manually input DB creds and Discord webhook URL into created secret in AWS Secret Manager


## Usage

```sh
# Create expense
curl -X POST http://{ALB endpoint}/create \
    -H "Content-Type: application/json" \
    -d '{"name":"Lunch","amount":1200,"expenseType":"Transaction"}'
    
# List all expense
curl http://{ALB endpoint}/expense

# Delete expense by ID(integer)
curl -X DELETE http://{ALB endpoint}/expense/{ID}
```

## Documentation

- [Learning Points](docs/learning-point.md)
- [Design Note](docs/design-note.md)
- [Decision Log](docs/decision-log.md)

## Architecture Diagram

![aws architecture diagram](attachment/aws%20architecture%20diagram.drawio.png)

## Next steps

- Add CloudWatch Alarms and Dashboard
- Create SNS Topic and Notification to external app
- Use VPC endpoint instead of NAT Gateway for ECS task - AWS service communication
