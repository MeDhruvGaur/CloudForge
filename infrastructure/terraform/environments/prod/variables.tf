variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "database_password" {
  type      = string
  sensitive = true
}

variable "domain_name" {
  type    = string
  default = "ecommerce.com"
}

variable "route53_zone_id" {
  type    = string
  default = ""
}

