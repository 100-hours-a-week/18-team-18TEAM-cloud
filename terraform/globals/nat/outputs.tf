output "nat_instance_ids" {
  description = "NAT instance IDs keyed by NAT logical key."
  value       = { for k, m in module.nat_instances : k => m.instance_id }
}

output "nat_eni_ids" {
  description = "Primary network interface IDs keyed by NAT logical key."
  value       = { for k, m in module.nat_instances : k => m.primary_network_interface_id }
}

output "nat_private_ips" {
  description = "NAT instance private IPs keyed by NAT logical key."
  value       = { for k, m in module.nat_instances : k => m.private_ip }
}

output "nat_eip_allocation_ids" {
  description = "NAT Elastic IP allocation IDs keyed by NAT logical key."
  value       = { for k, m in module.nat_instances : k => m.eip_allocation_id }
}

output "nat_eip_public_ips" {
  description = "NAT Elastic IP public IPs keyed by NAT logical key."
  value       = { for k, m in module.nat_instances : k => m.eip_public_ip }
}

output "nat_eip_association_ids" {
  description = "NAT Elastic IP association IDs keyed by NAT logical key."
  value       = { for k, m in module.nat_instances : k => m.eip_association_id }
}

output "managed_nat_security_group_ids" {
  description = "Managed NAT security group IDs keyed by NAT logical key."
  value       = var.nat_sg_migration_mode == "legacy" ? {} : { for k, m in module.nat_security_groups : k => m.id }
}
