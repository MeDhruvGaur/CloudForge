variable "cluster_id" {
  description = "Unique identifier for the Redis replication group"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where Redis is located"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for the Redis subnet group (usually database or private subnets)"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security group IDs granted inbound access to Redis"
  type        = list(string)
  default     = []
}

variable "node_type" {
  description = "Compute and memory capacity of the nodes"
  type        = string
  default     = "cache.t3.micro"
}

variable "num_cache_nodes" {
  description = "Number of cache clusters (nodes) in replication group"
  type        = number
  default     = 2
}

variable "engine_version" {
  description = "Version number of Redis engine"
  type        = string
  default     = "7.0"
}

variable "parameter_group_family" {
  description = "Parameter group family for Redis"
  type        = string
  default     = "redis7"
}

variable "automatic_failover_enabled" {
  description = "Specifies whether a read-only replica will be automatically promoted to read/write primary if the existing primary fails"
  type        = bool
  default     = true
}

variable "multi_az_enabled" {
  description = "Specifies whether Multi-AZ is enabled"
  type        = bool
  default     = true
}

variable "at_rest_encryption_enabled" {
  description = "Whether to enable encryption at rest"
  type        = bool
  default     = true
}

variable "transit_encryption_enabled" {
  description = "Whether to enable encryption in transit (TLS)"
  type        = bool
  default     = false
}

variable "auth_token" {
  description = "Password used to access a password protected server"
  type        = string
  default     = null
  sensitive   = true
}

variable "snapshot_retention_limit" {
  description = "Number of days for which ElastiCache retains automatic snapshots"
  type        = number
  default     = 7
}

variable "snapshot_window" {
  description = "Daily time range during which ElastiCache begins taking a daily snapshot"
  type        = string
  default     = "05:00-06:00"
}

variable "maintenance_window" {
  description = "Weekly time range during which system maintenance can occur"
  type        = string
  default     = "sun:06:00-sun:07:00"
}

variable "tags" {
  description = "Tags to attach to Redis resources"
  type        = map(string)
  default     = {}
}

