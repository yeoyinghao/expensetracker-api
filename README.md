

API for tracking expense.

## Project Overview
Spring Boot API that manages expenses. Run on Amazon ECS, Infrastructure managed by Terraform, CI/CD pipeline trigger on push with Github Actions.

## Architecture Diagram
![aws architecture diagram](attachment/aws%20architecture%20diagram.drawio.png)

## Tech Stack

- Java 17, Gradle, Spring Boot
- Docker
- Amazon ECS Fargate, ECR, VPC, IAM
- Github Actions
- Terraform

## AWS Infrastructure

1. Users access application through ALB with public IP address.
2. ALB forwards HTTP/HTTPS traffic to ECS Fargate tasks running in private subnets.
3. The ECS tasks connect to an Amazon RDS PostgreSQL database deployed in private subnets through port 5432.
4. Tasks retrieve database credentials from AWS Secrets Manager and send application logs to Amazon CloudWatch.
5. Private subnets use NAT Gateway for outbound access to AWS services and the internet.

## CI/CD flow

1. Commit code and push to dev branch
2. Create pull request and merge with main branch
3. Review Terraform plan
4. Docker build and test
5. Authorize with AWS
6. Push image tagged with commit SHA to ECR private repo
7. Update ECS task definition and service to point to latest task definition

## Learning Point

1. Docker run without port mapping
It is required to specify port when running container or it would not be accessible on internet.
`docker run -p <host_port>:<container_port>`

2. Docker multi-stage build that reduce image size
Building java compiled jar file with JDK, and only include JRE on final stage to run the compiled code.

3. Docker tag decides push destination
`<registry>/<repository>:<tag>`
If the registry is ECR repository, it will push image to there when doint `docker push`.

4. Authenticate Docker to ECR before pushing
Give credentials to docker for it to push to ECR.
`aws ecr get-login-password --region | docker login --username AWS --password-stdin`

5. AWS ECS networking required to access container
- Security group must have inbound rule accepting the port that application listen to.
- Subnet must have inbound rule accepting the port that application listen to.
- Container and Host port matching.

6. Resource cleanup
Since ECS create 2 CloudFormation stack, delete the stack after finish using and check if unwanted service are running:
- ECS Fargate
    - Task running?
    - Service set desired count = 0
- Load balancer
    - Charged even on Idle
- NAT gateway

## Next steps

Terraform define ECS structure, configure security group and IAM role
Use VPC endpoint instead of NAT Gateway for ECS task - AWS service communication
Make Github Actions manage ECS service and deployment adn separate it from Terraform
