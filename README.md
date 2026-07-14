<div align="center">

# expense-tracker

API for tracking expense.

</div>



## Project Overview

Spring Boot API that manages expenses. Run on Amazon ECS, Infrastructure managed by Terraform, CI/CD pipeline trigger on push with Github Actions.

## Prerequisites

- AWS CLI
- Terraform 1.15+

## Setup

```sh
terraform init
terraform apply -var-file=terraform.tfvars
```

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

## Architecture Diagram

![aws architecture diagram](attachment/aws%20architecture%20diagram.drawio.png)

## Next steps

- Use VPC endpoint instead of NAT Gateway for ECS task - AWS service communication
- Make Github Actions manage ECS service and deployment and separate it from Terraform
