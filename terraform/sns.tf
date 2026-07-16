resource "aws_sns_topic" "cloudwatch_alarm" {
  name = "expense-tracker-cloudwatch-alarm"
}

resource "aws_sns_topic_subscription" "expense_tracker_alarm" {
  topic_arn = aws_sns_topic.cloudwatch_alarm.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.discord.arn

  depends_on = [aws_lambda_permission.allow_sns]
}
