# Redis Subnet Group
resource "aws_elasticache_subnet_group" "this" {
  name        = "${var.cluster_id}-subnet-group"
  description = "Subnet group for Redis cluster ${var.cluster_id}"
  subnet_ids  = var.subnet_ids

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_id}-subnet-group"
    }
  )
}

# Redis Parameter Group
resource "aws_elasticache_parameter_group" "this" {
  name   = "${var.cluster_id}-params"
  family = var.parameter_group_family

  parameter {
    name  = "maxmemory-policy"
    value = "volatile-lru"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_id}-params"
    }
  )
}

# Redis Security Group
resource "aws_security_group" "redis" {
  name_prefix = "${var.cluster_id}-redis-sg-"
  description = "Security group for Redis ElastiCache cluster"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow Redis traffic from VPC or allowed security groups"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = var.security_group_ids
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_id}-redis-sg"
    }
  )
}

# ElastiCache Redis Replication Group
resource "aws_elasticache_replication_group" "this" {
  replication_group_id          = var.cluster_id
  description                   = "High availability Redis replication group for ecommerce platform"
  engine                        = "redis"
  engine_version                = var.engine_version
  node_type                     = var.node_type
  num_cache_clusters            = var.num_cache_nodes
  parameter_group_name          = aws_elasticache_parameter_group.this.name
  subnet_group_name             = aws_elasticache_subnet_group.this.name
  security_group_ids            = [aws_security_group.redis.id]
  port                          = 6379

  automatic_failover_enabled    = var.automatic_failover_enabled
  multi_az_enabled              = var.multi_az_enabled
  at_rest_encryption_enabled    = var.at_rest_encryption_enabled
  transit_encryption_enabled   = var.transit_encryption_enabled
  auth_token                    = var.transit_encryption_enabled ? var.auth_token : null

  snapshot_retention_limit      = var.snapshot_retention_limit
  snapshot_window               = var.snapshot_window
  maintenance_window            = var.maintenance_window
  auto_minor_version_upgrade    = true

  tags = merge(
    var.tags,
    {
      Name = var.cluster_id
    }
  )
}

