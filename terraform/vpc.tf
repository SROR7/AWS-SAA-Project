module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name = "task-vpc"
  cidr = "10.0.0.0/16"

  azs = [
    "us-east-1a",
    "us-east-1b"
  ]

  public_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]

  private_subnets = [
    "10.0.11.0/24",
    "10.0.12.0/24"
  ]

  create_igw = true

  enable_nat_gateway = true
  single_nat_gateway = false
  one_nat_gateway_per_az = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "task-vpc"
    Environment = "Production"
  }

  public_subnet_tags = {
    Name = "task-public-subnet"
  }

  private_subnet_tags = {
    Name = "task-private-subnet"
  }
}