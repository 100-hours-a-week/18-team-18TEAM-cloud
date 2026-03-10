output "vpn_network_interface_id" {
  value = aws_instance.vpn.primary_network_interface_id
}

output "vpn_cidr" {
  value = var.vpn_cidr
}

output "vpn_security_group_id" {
  value = var.vpn_sg_migration_mode == "new" ? null : aws_security_group.vpn[0].id
}

output "vpn_security_group_v2_id" {
  value = var.vpn_sg_migration_mode == "legacy" ? null : aws_security_group.vpn_v2[0].id
}
