output "monitoring_instance_id" {
  description = "Shared monitoring instance ID."
  value       = module.compute_single.instance_id
}

output "monitoring_private_ip" {
  description = "Shared monitoring instance private IPv4 address."
  value       = module.compute_single.private_ip
}

output "monitoring_public_ip" {
  description = "Shared monitoring instance public IPv4 address, if assigned."
  value       = module.compute_single.public_ip
}

output "ops_security_group_v2_id" {
  description = "New shared ops SG ID when ops_sg_migration_mode is dual/new."
  value       = var.ops_sg_migration_mode == "legacy" ? null : module.ops_sg_v2[0].id
}
