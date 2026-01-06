# output vpc IDs
output "vpc_ids" {
  description = "Map of VPC IDs"
  value       = { for k, v in var.vpcs : k => module.vpc[k].id }
}

# output subnet IDs
output "subnet_ids" {
  description = "Map of Subnet IDs"
  value       = { for k, v in var.subnets : k => module.subnets[k].id }
}

# output elastic IP allocation IDs
output "elastic_ip_allocation_ids" {
  description = "Map of Elastic IP allocation IDs"
  value       = { for k, v in var.elastic_ips : k => module.elastic_ip[k].allocation_id }
}