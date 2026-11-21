resource "aws_autoscaling_group" "web_asg" {
  name = "task-asg"

  min_size         = 2
  desired_capacity = 2
  max_size         = 4

  # EC2 instances in private subnets across 2 AZs
  vpc_zone_identifier = module.vpc.private_subnets

  # Attach ASG to ALB Target Group
  target_group_arns = [
    module.alb.target_groups["web"].arn
  ]

  launch_template {
    id      = aws_launch_template.web_server.id
    version = "$Latest"
  }

  health_check_type         = "ELB"
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "task-web-server"
    propagate_at_launch = true
  }
}