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

6. Manual Resource cleanup
Since ECS create 2 CloudFormation stack, delete the stack after finish using and check if unwanted service are running:
- ECS Fargate
    - Task running?
    - Service set desired count = 0
- Load balancer
    - Charged even on Idle
- NAT gateway
* Resolved by managing infrastructure with terraform destroy

7. Bootstrap image issue
If terraform manage ecs and task, the service try to create task that dont have image yet. CI/CD is still building the image

8. Make Github Actions manage the ECS task, Terraform Manage the ECR and ECS service

9. Use Github secrets to pass environment vars into Github Actions

10. Take note of what github environment is the Github Actions running in, env vars are tied to environments

11. Github Actions need post-Terraform apply RDS value to give DB_HOST env vars

12. Terraform Destroy needs different IAM role permission

13. Terraform lifecycle ignore_changes for parts that want to change manually or managed by other party

14. Bootstrap Terraform issue
Create s3 bucket with local backend, then use another folder for Infra Terraform using the created s3 bucket. Migrate state if needed.

15. Failing terraform plan or apply might keep the lock on. terraform refresh to confirm and Force unlock.

16. The ECS service and aws_ecs_cluster_capacity_providers both depend only on the cluster. Terraform can create them concurrently. The service should explicitly depend on the capacity-provider association when using FARGATE_SPOT.