resource "aws_cloudwatch_metric_alarm" "cpu" {
  alarm_name          = "et-ecs-cpu"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 120
  statistic           = "Average"
  threshold           = 80

  alarm_description = "ECS service CPU utilization >= 80%"
  alarm_actions     = [aws_sns_topic.cloudwatch_alarm.arn]

  dimensions = {
    ClusterName = aws_ecs_cluster.app.name
    ServiceName = aws_ecs_service.app.name
  }
}