locals {
  ecs_task_family              = "${local.application_name}-api"
  ecs_task_role_name           = "etracker-ecs-task-role"
  ecs_task_execution_role_name = "etracker-ecs-task-execution-role"

  # Bootstrap ECS creation by not starting service, CI manages the service count
  ecs_desired_count = 0
}

resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/${local.ecs_task_family}"
  retention_in_days = 7
}

data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_execution" {
  name               = local.ecs_task_execution_role_name
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}

resource "aws_iam_role" "ecs_task" {
  name               = local.ecs_task_role_name
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_execution_get_secret" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = aws_iam_policy.get_secret.arn
}

# Terraform registers the initial task definition so the ECS service can be
# created in a single apply. Subsequent revisions and deployments are managed
# by GitHub Actions. The service ignores task_definition drift for that reason.
resource "aws_ecs_task_definition" "bootstrap" {
  family                   = local.ecs_task_family
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name      = local.ecs_task_family
      image     = "${aws_ecr_repository.app.repository_url}:${local.image_tag}"
      essential = true

      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "DB_HOST"
          value = aws_db_instance.app.address
        },
        {
          name  = "DB_PORT"
          value = tostring(aws_db_instance.app.port)
        },
        {
          name  = "DB_NAME"
          value = var.db_name
        }
      ]

      secrets = [
        {
          name      = "SPRING_DATASOURCE_USERNAME"
          valueFrom = "${aws_secretsmanager_secret.app.arn}:db_username::"
        },
        {
          name      = "SPRING_DATASOURCE_PASSWORD"
          valueFrom = "${aws_secretsmanager_secret.app.arn}:db_password::"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.app.name
          awslogs-region        = local.region_apne1
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  # This resource only bootstraps the task family. Runtime container settings
  # are owned by the deployed ECS revision and must not be reset by later
  # Terraform applies.
  lifecycle {
    ignore_changes = [container_definitions]
  }
}

resource "aws_ecs_cluster" "app" {
  name = "etracker-cluster"
}

# Deafult to fargate spot
resource "aws_ecs_cluster_capacity_providers" "app" {
  cluster_name = aws_ecs_cluster.app.name

  capacity_providers = [
    "FARGATE",
    "FARGATE_SPOT"
  ]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
  }
}

# Specify capacity provider strategy instead of launch type
resource "aws_ecs_service" "app" {
  name            = local.ecs_task_family
  cluster         = aws_ecs_cluster.app.id
  task_definition = aws_ecs_task_definition.bootstrap.arn
  desired_count   = local.ecs_desired_count

  # Use Fargate Spot only
  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
    base              = 0
  }

  network_configuration {
    subnets          = [aws_subnet.private_a.id, aws_subnet.private_c.id]
    security_groups  = [aws_security_group.web_tier.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = local.ecs_task_family
    container_port   = 8080
  }

  lifecycle {
    ignore_changes = [
      task_definition,
      desired_count
    ]
  }

  depends_on = [
    aws_lb_listener.http,
    aws_ecs_cluster_capacity_providers.app
  ]
}
