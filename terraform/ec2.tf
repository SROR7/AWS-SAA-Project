data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_launch_template" "web_server" {
  name_prefix   = "task-web"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"

  vpc_security_group_ids = [
    module.ec2_sg.security_group_id
  ]

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 20
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name      = "task-web-server"
      ManagedBy = "Terraform"
    }
  }
}