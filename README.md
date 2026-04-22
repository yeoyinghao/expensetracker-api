
API for tracking expense.

### Steps to create
1. Create spring boot API
2. Add endpoint `GET` `/create`
3. Gradle build and test run on localhost:8080/create
4. Dockerize application
5. Push to ECR
6. Create task, service, cluster on ECS. Run task on Fargate. Configure public network. Test on public IP address to access the endpoint.


### Key takeways
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

