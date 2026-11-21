resource "aws_db_subnet_group" "task_rds_subnet_group" {
  name        = "task-rds-subnet-group"
  description = "Private subnets for RDS Multi-AZ"

  subnet_ids = module.vpc.private_subnets

  tags = {
    Name        = "task-rds-subnet-group"
    Environment = "Production"
  }
}


resource "aws_db_instance" "task_rds" {
  identifier = "task-rds"

  engine         = "postgres"
  engine_version = "16"
  instance_class = "db.t3.small"

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = "taskdb"
  username = "dbadmin"

  manage_master_user_password = true

  port = 5432

  multi_az             = true
  db_subnet_group_name = aws_db_subnet_group.task_rds_subnet_group.name

  vpc_security_group_ids = [
    module.task_rds_sg.security_group_id
  ]

  publicly_accessible = false

  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  copy_tags_to_snapshot   = true

  maintenance_window        = "Sun:04:00-Sun:05:00"
  auto_minor_version_upgrade = true

  enabled_cloudwatch_logs_exports = [
    "postgresql",
    "upgrade"
  ]

  deletion_protection = false
  skip_final_snapshot = true

  tags = {
    Name        = "task-rds"
    Environment = "Production"
  }
}