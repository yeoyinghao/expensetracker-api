output "rds_endpoint" {
  description = "RDS endpoint hostname and port."
  value       = aws_db_instance.app.endpoint
}

output "rds_database_name" {
  description = "Initial database name."
  value       = aws_db_instance.app.db_name
}
