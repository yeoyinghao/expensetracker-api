# VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "etracker-vpc"
  }
}

## Subnet
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public_c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-northeast-1c"
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

# Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

## Associate route tables with subnets
resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "public_c" {
  subnet_id      = aws_subnet.public_c.id
  route_table_id = aws_route_table.public.id
}

# ECS Security Group
resource "aws_security_group" "web_tier" {
  name        = "app-access-sg"
  description = "Allow HTTP/HTTPS traffic access application"
  vpc_id      = aws_vpc.main.id
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP from anywhere"
  }
}

# RDS Security Group
resource "aws_security_group" "db_tier" {
  name        = "rds-sg"
  description = "Allow application access RDS"
  vpc_id      = aws_vpc.main.id
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.web_tier.id]
    description     = "Allow PostgreSQL only from web tier"
  }
}

# HTTPS outbound for AWS APIs: Secrets Manager, ECR, CloudWatch Logs, etc.
resource "aws_security_group_rule" "allow_https_outbound" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web_tier.id
  description       = "Allow HTTPS outbound"
}

# PostgreSQL outbound to RDS
resource "aws_vpc_security_group_egress_rule" "allow_postgres_outbound" {
  security_group_id            = aws_security_group.web_tier.id
  referenced_security_group_id = aws_security_group.db_tier.id
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
}