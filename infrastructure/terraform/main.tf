terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
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
      Environment = var.environment
      Project     = "ecommerce-platform"
      ManagedBy   = "Terraform"
      CostCenter  = "IT-123"
    }
  }
}

# Configure Kubernetes provider connected to EKS
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_id]
  }
}

# Configure Helm provider connected to EKS
provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_id]
    }
  }
}

# 1. VPC Module
module "vpc" {
  source = "./modules/vpc"

  name               = "ecommerce-${var.environment}"
  cidr               = var.vpc_cidr
  azs                = var.availability_zones
  private_subnets    = var.private_subnet_cidrs
  public_subnets     = var.public_subnet_cidrs
  database_subnets   = var.database_subnet_cidrs
  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway
  cluster_name       = "ecommerce-${var.environment}"

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}

# 2. EKS Cluster Module
module "eks" {
  source = "./modules/eks"

  cluster_name    = "ecommerce-${var.environment}"
  cluster_version = var.kubernetes_version
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets

  node_groups = {
    general = {
      desired_size   = var.node_group_general_desired
      max_size       = var.node_group_general_max
      min_size       = var.node_group_general_min
      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"

      k8s_labels = {
        Environment = var.environment
        NodeGroup   = "general"
      }
      taints = []
    }

    spot = {
      desired_size   = var.node_group_spot_desired
      max_size       = var.node_group_spot_max
      min_size       = var.node_group_spot_min
      instance_types = ["t3.medium", "t3a.medium", "t2.medium"]
      capacity_type  = "SPOT"

      k8s_labels = {
        Environment = var.environment
        NodeGroup   = "spot"
      }

      taints = [{
        key    = "spot"
        value  = "true"
        effect = "NO_SCHEDULE"
      }]
    }
  }

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}

# 3. RDS PostgreSQL Module
module "rds" {
  source = "./modules/rds"

  identifier = "ecommerce-${var.environment}"

  engine         = "postgres"
  engine_version = "15.3"
  instance_class = var.db_instance_class

  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_max_allocated_storage

  db_name  = var.database_name
  username = var.database_username
  password = var.database_password

  vpc_security_group_ids = [module.vpc.default_security_group_id]
  subnet_ids             = length(module.vpc.database_subnets) > 0 ? module.vpc.database_subnets : module.vpc.private_subnets

  backup_retention_period = var.db_backup_retention_period
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"
  multi_az               = var.environment == "prod" ? true : false

  monitoring_interval = 60

  performance_insights_enabled          = true
  performance_insights_retention_period = 7

  parameters = [
    {
      name  = "shared_preload_libraries"
      value = "pg_stat_statements"
    },
    {
      name  = "pg_stat_statements.track"
      value = "all"
    }
  ]

  tags = {
    Environment = var.environment
    Tier        = "Database"
  }
}

# 4. ElastiCache Redis Module
module "redis" {
  source = "./modules/redis"

  cluster_id             = "ecommerce-${var.environment}"
  engine_version         = "7.0"
  node_type              = var.redis_node_type
  num_cache_nodes        = var.redis_num_nodes
  parameter_group_family = "redis7"

  vpc_id             = module.vpc.vpc_id
  subnet_ids         = length(module.vpc.database_subnets) > 0 ? module.vpc.database_subnets : module.vpc.private_subnets
  security_group_ids = [module.vpc.default_security_group_id]

  automatic_failover_enabled = var.environment == "prod" ? true : false
  multi_az_enabled          = var.environment == "prod" ? true : false

  snapshot_retention_limit = 7
  snapshot_window         = "05:00-06:00"

  tags = {
    Environment = var.environment
    Tier        = "Cache"
  }
}

# 5. Networking & ALB Module
module "networking" {
  source = "./modules/networking"

  name            = "ecommerce-${var.environment}"
  vpc_id          = module.vpc.vpc_id
  public_subnets  = module.vpc.public_subnets
  domain_name     = var.domain_name
  route53_zone_id = var.route53_zone_id

  tags = {
    Environment = var.environment
  }
}

# 6. S3 Buckets for Logs, Backups, and Assets
resource "aws_s3_bucket" "application_logs" {
  bucket = "ecommerce-${var.environment}-logs-${var.aws_region}"

  tags = {
    Name        = "ecommerce-${var.environment}-logs"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_versioning" "application_logs" {
  bucket = aws_s3_bucket.application_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "application_logs" {
  bucket = aws_s3_bucket.application_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "application_logs" {
  bucket = aws_s3_bucket.application_logs.id

  rule {
    id = "log_lifecycle"

    filter {
      prefix = "logs/"
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }

    status = "Enabled"
  }
}

# S3 Bucket for Velero and Database Backups
resource "aws_s3_bucket" "backups" {
  bucket = "ecommerce-${var.environment}-backups-${var.aws_region}"

  tags = {
    Name        = "ecommerce-${var.environment}-backups"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_versioning" "backups" {
  bucket = aws_s3_bucket.backups.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "backups" {
  bucket = aws_s3_bucket.backups.id

  rule {
    id = "backup_lifecycle"

    filter {
      prefix = "backups/"
    }

    transition {
      days          = 30
      storage_class = "INTELLIGENT_TIERING"
    }

    expiration {
      days = 180
    }

    status = "Enabled"
  }
}

# 7. CloudFront CDN Distribution
resource "aws_cloudfront_distribution" "application" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "E-commerce production CDN for static assets and UI"
  default_root_object = "index.html"

  origin {
    domain_name = module.networking.alb_dns_name
    origin_id   = "application-alb"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "application-alb"

    forwarded_values {
      query_string = true
      headers      = ["*"]

      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
    minimum_protocol_version       = "TLSv1.2_2021"
  }

  tags = {
    Environment = var.environment
  }
}

