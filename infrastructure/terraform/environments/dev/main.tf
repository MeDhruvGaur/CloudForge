terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Environment = "dev"
      Project     = "ecommerce-platform"
      ManagedBy   = "Terraform"
    }
  }
}

module "root" {
  source = "../../"

  aws_region                 = var.aws_region
  environment                = "dev"
  single_nat_gateway         = true
  enable_nat_gateway         = true
  node_group_general_desired = 1
  node_group_general_min     = 1
  node_group_general_max     = 2
  node_group_spot_desired    = 1
  node_group_spot_min        = 0
  node_group_spot_max        = 2
  db_instance_class          = "db.t3.micro"
  db_allocated_storage       = 20
  db_max_allocated_storage   = 50
  db_backup_retention_period = 7
  redis_node_type            = "cache.t3.micro"
  redis_num_nodes            = 1
  database_password          = var.database_password
}

