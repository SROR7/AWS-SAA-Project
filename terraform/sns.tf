resource "aws_sns_topic" "task_alerts" {
  name = "task-alerts"

  tags = {
    Name        = "task-alerts"
    Environment = "Production"
  }
}

resource "aws_sns_topic_subscription" "task_email_alerts" {
  topic_arn = aws_sns_topic.task_alerts.arn
  protocol  = "email"
  endpoint  = "YOUR_EMAIL@example.com"
}