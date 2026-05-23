module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.5.0"

  name = "alchemyst-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["ap-south-1a"]
  private_subnets = ["10.0.1.0/24"]
  public_subnets  = ["10.0.2.0/24"]

  enable_nat_gateway = false

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
