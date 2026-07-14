## AWS Infrastructure

1. Users access application through ALB with public IP address.
2. ALB forwards HTTP/HTTPS traffic to ECS Fargate tasks running in private subnets.
3. The ECS tasks connect to an Amazon RDS PostgreSQL database deployed in private subnets through port 5432.
4. Tasks retrieve database credentials from AWS Secrets Manager and send application logs to Amazon CloudWatch.
5. Private subnets use NAT Gateway for outbound access to AWS services and the internet.

![aws architecture diagram](../attachment/aws%20architecture%20diagram.drawio.png)

## CI/CD flow

1. Commit code and push to dev branch
2. Create pull request and merge with main branch
3. Review Terraform plan
4. Docker build and test
5. Authorize with AWS
6. Push image tagged with commit SHA to ECR private repo
7. Update ECS task definition and service to point to latest task definition