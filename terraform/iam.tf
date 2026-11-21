resource "aws_iam_role" "task_ec2_ssm_role" {
  name = "task-ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "task-ec2-ssm-role"
  }
}

resource "aws_iam_role_policy_attachment" "task_ssm_policy" {
  role = aws_iam_role.task_ec2_ssm_role.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "task_ec2_instance_profile" {
  name = "task-ec2-instance-profile"

  role = aws_iam_role.task_ec2_ssm_role.name
}