output "vpc_id" {
  value = module.root.vpc_id
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

