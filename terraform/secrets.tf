resource "aws_secretsmanager_secret" "app" {
  name = "expense-tracker-secret"
}

resource "aws_iam_policy" "get_secret" {
  name        = "GetSecretPolicy"
  description = "Allow reading application secrets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "secretsmanager:GetSecretValue"
      ]
      Resource = [
        aws_secretsmanager_secret.app.arn
      ]
    }]
  })
}