# Package the Lambda function code
data "archive_file" "example" {
  type        = "zip"
  source_file = "${path.module}/../lambda/discord-notifier/lambda_function.py"
  output_path = "${path.module}/../lambda/function.zip"
}

resource "aws_lambda_function" "discord" {
  filename      = data.archive_file.example.output_path
  function_name = "discord-notifier"
  role          = aws_iam_role.lambda.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.14"
  timeout       = 30
  memory_size   = 128

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

# lambda initiate by assume role so it has credentials to other AWS service
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
resource "aws_iam_role_policy_attachment" "lambda_get_secret" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.get_secret.arn
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
  source_arn    = aws_sns_topic.cloudwatch_alarm.arn
}