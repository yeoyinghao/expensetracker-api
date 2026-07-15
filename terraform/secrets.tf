resource "aws_secretsmanager_secret" "app" {
  name = "expense-tracker-secret"
}