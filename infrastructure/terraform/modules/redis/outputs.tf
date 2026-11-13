output "replication_group_id" {
  description = "The ID of the Redis replication group"
  value       = aws_elasticache_replication_group.this.id
}

output "primary_endpoint_address" {
  description = "The address of the endpoint for the primary node in the replication group"
  value       = aws_elasticache_replication_group.this.primary_endpoint_address
}

output "reader_endpoint_address" {
  description = "The address of the endpoint for the reader nodes in the replication group"
  value       = aws_elasticache_replication_group.this.reader_endpoint_address
}

output "port" {
  description = "The port number on which the cache accepts connections"
  value       = aws_elasticache_replication_group.this.port
}

output "security_group_id" {
  description = "Security group ID created for Redis"
  value       = aws_security_group.redis.id
}

