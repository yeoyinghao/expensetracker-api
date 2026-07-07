# ECS Security Group
resource "aws_security_group" "web_tier" {
  name        = "app-access-sg"
  description = "Allow ALB access to ECS tasks"
  vpc_id      = aws_vpc.main.id
}

# RDS Security Group
resource "aws_security_group" "db_tier" {
  name        = "rds-sg"
  description = "Allow application access of RDS"
  vpc_id      = aws_vpc.main.id
}

# ALB security group
resource "aws_security_group" "alb" {
  name   = "etracker-alb-sg"
  vpc_id = aws_vpc.main.id
}

# ECS task inbound from ALB
resource "aws_vpc_security_group_ingress_rule" "ecs_inbound" {
  security_group_id            = aws_security_group.web_tier.id
  referenced_security_group_id = aws_security_group.alb.id
  ip_protocol                  = "tcp"
  from_port                    = 8080
  to_port                      = 8080
}

# HTTPS outbound for AWS APIs: ECR, CloudWatch Logs, and future VPC endpoints.
resource "aws_vpc_security_group_egress_rule" "allow_https_outbound" {
  security_group_id = aws_security_group.web_tier.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  description       = "Allow HTTPS outbound"
}

# ECS outbound to RDS
resource "aws_vpc_security_group_egress_rule" "ecs_to_rds" {
  security_group_id            = aws_security_group.web_tier.id
  referenced_security_group_id = aws_security_group.db_tier.id
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
}

# RDS inbound from ECS
resource "aws_vpc_security_group_ingress_rule" "allow_postgres_inbound" {
  security_group_id            = aws_security_group.db_tier.id
  referenced_security_group_id = aws_security_group.web_tier.id
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
}

# ALB inbound from internet
resource "aws_vpc_security_group_ingress_rule" "alb_internet_inbound" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

# ALB outbound to ECS task
resource "aws_vpc_security_group_egress_rule" "alb_allow_ecs_outbound" {
  security_group_id            = aws_security_group.alb.id
  referenced_security_group_id = aws_security_group.web_tier.id
  ip_protocol                  = "tcp"
  from_port                    = 8080
  to_port                      = 8080
}
