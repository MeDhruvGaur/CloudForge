output "vpc_id" {
  value = module.root.vpc_id
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

