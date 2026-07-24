resource "aws_cloudwatch_metric_alarm" "cpu" {
  alarm_name        = "et-ecs-cpu"
  alarm_description = "ECS service CPU utilization >= 80%"
  namespace         = "AWS/ECS"
  dimensions = {
    ClusterName = aws_ecs_cluster.app.name
    ServiceName = aws_ecs_service.app.name
  }
  metric_name         = "CPUUtilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  period              = 120
  statistic           = "Average"
  threshold           = 80
  evaluation_periods  = 2
  alarm_actions       = [aws_sns_topic.cloudwatch_alarm.arn]
  ok_actions          = [aws_sns_topic.cloudwatch_alarm.arn]
}