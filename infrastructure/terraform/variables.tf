variable "aws_region" {
  description = "AWS deployment region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "kubernetes_version" {
  description = "Kubernetes control plane version"
  type        = string
  default     = "1.27"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private application subnet CIDRs"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "database_subnet_cidrs" {
  description = "Database isolated subnet CIDRs"
  type        = list(string)
  default     = ["10.0.201.0/24", "10.0.202.0/24", "10.0.203.0/24"]
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateways"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Deploy a single NAT Gateway instead of one per AZ"
  type        = bool
  default     = false
}

variable "node_group_general_desired" {
  description = "Desired number of on-demand general worker nodes"
  type        = number
  default     = 2
}

variable "node_group_general_min" {
  description = "Minimum number of on-demand general worker nodes"
  type        = number
  default     = 2
}

variable "node_group_general_max" {
  description = "Maximum number of on-demand general worker nodes"
  type        = number
  default     = 5
}

variable "node_group_spot_desired" {
  description = "Desired number of spot worker nodes"
  type        = number
  default     = 1
}

variable "node_group_spot_min" {
  description = "Minimum number of spot worker nodes"
  type        = number
  default     = 1
}

variable "node_group_spot_max" {
  description = "Maximum number of spot worker nodes"
  type        = number
  default     = 10
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.medium"
}

variable "db_allocated_storage" {
  description = "Allocated storage for RDS in GB"
  type        = number
  default     = 100
}

variable "db_max_allocated_storage" {
  description = "Max auto-scaled storage for RDS in GB"
  type        = number
  default     = 500
}

variable "database_name" {
  description = "Primary database name"
  type        = string
  default     = "ecommerce"
}

variable "database_username" {
  description = "Database master username"
  type        = string
  default     = "dbadmin"
}

variable "database_password" {
  description = "Database master password"
  type        = string
  default     = "ChangeMeInProdSecure123!"
  sensitive   = true
}

variable "db_backup_retention_period" {
  description = "Number of days to retain automated database backups"
  type        = number
  default     = 30
}

variable "redis_node_type" {
  description = "Cache node type for Redis"
  type        = string
  default     = "cache.t3.micro"
}

variable "redis_num_nodes" {
  description = "Number of nodes in Redis cluster"
  type        = number
  default     = 2
}

variable "domain_name" {
  description = "Base domain name for application services"
  type        = string
  default     = "ecommerce.com"
}

variable "route53_zone_id" {
  description = "Route 53 hosted zone ID for public DNS mapping"
  type        = string
  default     = ""
}

