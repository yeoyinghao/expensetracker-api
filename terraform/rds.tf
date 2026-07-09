variable "db_password" {
  description = "RDS master password. Set with TF_VAR_db_password, preferably loaded from an ignored .env file."
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Initial database name for the practice RDS instance."
  type        = string
  default     = "etracker"
}

variable "db_username" {
  description = "RDS master username."
  type        = string
  default     = "admin"
}

resource "aws_db_subnet_group" "app" {
  name       = "etracker-db-subnet-group"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_c.id]
}

resource "aws_db_instance" "app" {
  identifier             = "etracker-postgres-db"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  engine                 = "postgres"
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.app.name
  vpc_security_group_ids = [aws_security_group.db_tier.id]
  publicly_accessible    = false
  skip_final_snapshot    = true
  deletion_protection    = false
}