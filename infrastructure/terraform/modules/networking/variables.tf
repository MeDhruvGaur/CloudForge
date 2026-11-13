variable "name" {
  description = "Name prefix for networking resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnet IDs for the ALB"
  type        = list(string)
}

variable "domain_name" {
  description = "Root domain name for ecommerce platform (e.g. ecommerce.com)"
  type        = string
  default     = "ecommerce.com"
}

variable "route53_zone_id" {
  description = "Route 53 Hosted Zone ID"
  type        = string
  default     = ""
}

variable "acm_certificate_arn" {
  description = "ARN of ACM SSL/TLS certificate"
  type        = string
  default     = ""
}

variable "enable_dr_health_check" {
  description = "Enable Route53 health check for DR failover"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to attach to networking resources"
  type        = map(string)
  default     = {}
}

