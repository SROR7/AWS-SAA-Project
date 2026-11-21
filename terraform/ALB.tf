module "alb" {
  source = "terraform-aws-modules/alb/aws"

  name               = "task-alb"
  load_balancer_type = "application"
  internal           = false

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets

  # ALB Security Group
  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      description = "HTTP traffic from internet"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = module.vpc.vpc_cidr_block
    }
  }

  # Target Group
  target_groups = {
    web = {
      name_prefix      = "web-"
      protocol         = "HTTP"
      port             = 80
      target_type      = "instance"
      create_attachment = false

      health_check = {
        enabled             = true
        path                = "/"
        protocol            = "HTTP"
        matcher             = "200"
        interval            = 30
        healthy_threshold   = 2
        unhealthy_threshold = 3
      }
    }
  }

  # Listener
  listeners = {
    http = {
      port     = 80
      protocol = "HTTP"

      forward = {
        target_group_key = "web"
      }
    }
  }

  tags = {
    Environment = "Production"
    Project     = "task-alb"
  }
}