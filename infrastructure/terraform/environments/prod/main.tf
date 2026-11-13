terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "ecommerce-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-lock"
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Environment = "production"
      Project     = "ecommerce-platform"
      ManagedBy   = "Terraform"
    }
  }
}

module "root" {
  source = "../../"

  aws_region                 = var.aws_region
  environment                = "prod"
  single_nat_gateway         = false
  enable_nat_gateway         = true
  node_group_general_desired = 2
  node_group_general_min     = 2
  node_group_general_max     = 5
  node_group_spot_desired    = 1
  node_group_spot_min        = 1
  node_group_spot_max        = 10
  db_instance_class          = "db.t3.medium"
  db_allocated_storage       = 100
  db_max_allocated_storage   = 500
  db_backup_retention_period = 30
  redis_node_type            = "cache.t3.micro"
  redis_num_nodes            = 2
  database_password          = var.database_password
  domain_name                = var.domain_name
  route53_zone_id            = var.route53_zone_id
}

output "eks_cluster_id" {
  value = module.root.eks_cluster_id
}

output "eks_cluster_endpoint" {
  value = module.root.eks_cluster_endpoint
}

output "rds_endpoint" {
  value = module.root.rds_endpoint
}

output "redis_primary_endpoint" {
  value = module.root.redis_primary_endpoint
}

output "alb_dns_name" {
  value = module.root.alb_dns_name
}

output "cloudfront_domain_name" {
  value = module.root.cloudfront_domain_name
}

