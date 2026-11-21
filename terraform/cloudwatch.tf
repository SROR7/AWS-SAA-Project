resource "aws_cloudwatch_metric_alarm" "task_high_cpu" {
  alarm_name          = "task-high-cpu"
  alarm_description   = "Alert when EC2 CPU utilization is high"
  comparison_operator = "GreaterThanOrEqualToThreshold"

  evaluation_periods  = 2
  period              = 300
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  statistic           = "Average"
  threshold           = 70

  dimensions = {
    AutoScalingGroupName = "YOUR_ASG_NAME"
  }

  alarm_actions = [
    aws_sns_topic.task_alerts.arn
  ]

  ok_actions = [
    aws_sns_topic.task_alerts.arn
  ]

  tags = {
    Name        = "task-high-cpu"
    Environment = "Production"
  }
}