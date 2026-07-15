resource "aws_lambda_function" "discord" {
  function_name = "discord-notifier"

  role        = aws_iam_role.lambda.arn
  handler     = "lambda_function.lambda_handler"
  runtime     = "python3.14"
  timeout     = 5
  memory_size = 128

  lifecycle {
    ignore_changes = [
      filename,
      source_code_hash
    ]
  }

  environment {
    variables = {
      SECRET_NAME = aws_secretsmanager_secret.app.name
    }
  }
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda" {
  name               = "lambda-get-secret-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

# Enable lambda to get secrets
resource "aws_iam_role_policy" "lambda_get_secret" {
  name = "lambda-get-secret"
  role = aws_iam_role.lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "secretsmanager:GetSecretValue"
      Resource = aws_secretsmanager_secret.app.arn
    }]
  })
}

# Attach CloudWatch log policy to lambda role
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Allow SNS to invoke lambda
resource "aws_lambda_permission" "allow_sns" {
    statement_id  = "AllowExecutionFromSNS"
    action        = "lambda:InvokeFunction"
    function_name = aws_lambda_function.discord.function_name
    principal     = "sns.amazonaws.com"
    source_arn    = aws_sns_topic.user_updates.arn
  }