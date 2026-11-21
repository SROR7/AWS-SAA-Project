module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "aws-saa-ec2-sg"
  description = "Security group for private EC2 instances"
  vpc_id      = module.vpc.vpc_id

  ingress_with_source_security_group_id = [
    {
      from_port                = 80
      to_port                  = 80
      protocol                 = "tcp"
      description              = "HTTP from ALB"
      source_security_group_id = module.alb.security_group_id
    }
  ]

  egress_rules = ["all-all"]

  tags = {
    Name = "aws-saa-ec2-sg"
  }
}   

module "task_rds_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "task-rds-sg"
  description = "Security group for RDS PostgreSQL"
  vpc_id      = module.vpc.vpc_id

  ingress_with_source_security_group_id = [
    {
      from_port                = 5432
      to_port                  = 5432
      protocol                 = "tcp"
      description              = "PostgreSQL from EC2"
      source_security_group_id = module.security_group.security_group_id
    }
  ]

  egress_rules = ["all-all"]

  tags = {
    Name = "task-rds-sg"
  }
}