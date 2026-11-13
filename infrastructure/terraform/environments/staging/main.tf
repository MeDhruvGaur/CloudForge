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
      Environment = "staging"
      Project     = "ecommerce-platform"
      ManagedBy   = "Terraform"
    }
  }
}

module "root" {
  source = "../../"

  aws_region                 = var.aws_region
  environment                = "staging"
  single_nat_gateway         = false
  enable_nat_gateway         = true
  node_group_general_desired = 2
  node_group_general_min     = 2
  node_group_general_max     = 3
  node_group_spot_desired    = 1
  node_group_spot_min        = 1
  node_group_spot_max        = 4
  db_instance_class          = "db.t3.medium"
  db_allocated_storage       = 50
  db_max_allocated_storage   = 100
  db_backup_retention_period = 14
  redis_node_type            = "cache.t3.micro"
  redis_num_nodes            = 2
  database_password          = var.database_password
}

output "eks_cluster_id" {
  value = module.root.eks_cluster_id
}

output "rds_endpoint" {
  value = module.root.rds_endpoint
}

output "alb_dns_name" {
  value = module.root.alb_dns_name
}

