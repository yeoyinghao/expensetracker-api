

API for tracking expense.

## Project Overview
Spring Boot API that manages expenses. Run on Amazon ECS, Infrastructure managed by Terraform, CI/CD pipeline trigger on push with Github Actions.

## Architecture Diagram
<img width="1047" height="722" alt="aws_architecture_diagram" src="https://github.com/user-attachments/assets/a761a41a-75c1-438e-9a32-cd2354d053cc" />

## Tech Stack

- Java 17, Gradle, Spring Boot
- Docker
- Amazon ECS Fargate, ECR, VPC, IAM
- Github Actions
- Terraform

## AWS Infrastructure

1. Users access endpoint of public IP address of the application.
2. Request go to the ECS Fargate Task of that IP address.
3. Task container talks with RDS that resides in private subnet through port 5432.
4. Task uses DB credentials from Secrets Manager to authenticate RDS.
5. Task application logs are output to CloudWatch.
6. 

## Improved AWS Infrastructure

1. 

## CI/CD flow

1. Commit code and push to main branch
2. Trigger aws-ecs.yml action
3. Docker build and test
4. Authorize with AWS
5. Push image to ECR private repo
6. Update ECS task definition and service to point to latest task definition

## Troubleshooting

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

Terraform define ECR and ECS structure, configure security group and IAM role
