variable "name" {
  description = "Name prefix for VPC resources"
  type        = string
}

variable "cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "List of availability zones"
  type        = list(string)
}

variable "public_subnets" {
  description = "Public subnet CIDR blocks"
  type        = list(string)
}

variable "private_subnets" {
  description = "Private application subnet CIDR blocks"
  type        = list(string)
}

variable "database_subnets" {
  description = "Database subnet CIDR blocks"
  type        = list(string)
  default     = []
}

variable "enable_nat_gateway" {
  description = "Provision NAT Gateways for private subnet outbound internet"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway instead of one per AZ (cost-saving for dev)"
  type        = bool
  default     = false
}

variable "cluster_name" {
  description = "EKS Cluster name for subnet tags"
  type        = string
  default     = "ecommerce-production"
}

variable "tags" {
  description = "Tags to attach to resources"
  type        = map(string)
  default     = {}
}
