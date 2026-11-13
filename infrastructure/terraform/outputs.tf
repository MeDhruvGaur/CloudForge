output "vpc_id" {
  description = "The ID of the provisioned VPC"
  value       = module.vpc.vpc_id
}

output "eks_cluster_id" {
  description = "EKS Cluster Name and ID"
  value       = module.eks.cluster_id
}

output "eks_cluster_endpoint" {
  description = "EKS Kubernetes control plane API endpoint"
  value       = module.eks.cluster_endpoint
}

output "eks_oidc_issuer" {
  description = "OIDC Issuer URL for IAM Roles for Service Accounts (IRSA)"
  value       = module.eks.oidc_issuer
}

output "rds_endpoint" {
  description = "RDS PostgreSQL connection endpoint"
  value       = module.rds.db_instance_endpoint
}

output "rds_address" {
  description = "RDS PostgreSQL hostname"
  value       = module.rds.db_instance_address
}

output "redis_primary_endpoint" {
  description = "Redis ElastiCache primary endpoint address"
  value       = module.redis.primary_endpoint_address
}

output "redis_reader_endpoint" {
  description = "Redis ElastiCache reader endpoint address"
  value       = module.redis.reader_endpoint_address
}

output "alb_dns_name" {
  description = "Public DNS name for the Application Load Balancer"
  value       = module.networking.alb_dns_name
}

output "cloudfront_domain_name" {
  description = "CloudFront CDN domain name"
  value       = aws_cloudfront_distribution.application.domain_name
}

output "application_logs_bucket" {
  description = "S3 bucket for application access and runtime logs"
  value       = aws_s3_bucket.application_logs.id
}

output "backups_bucket" {
  description = "S3 bucket for disaster recovery backups"
  value       = aws_s3_bucket.backups.id
}

