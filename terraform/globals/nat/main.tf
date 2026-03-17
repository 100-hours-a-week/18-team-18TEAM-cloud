locals {
  new_nat_sg_ids = var.nat_sg_migration_mode == "legacy" ? {} : {
    for k, v in module.nat_security_groups : k => v.id
  }
}

module "nat_security_groups" {
  source = "../../modules/security_group"

  for_each = var.nat_sg_migration_mode == "legacy" ? {} : var.nat_instances

  name        = "bizkit-sg-${split("_", each.key)[0]}-nat"
  description = "[${split("_", each.key)[0]}] NAT instance security group for outbound internet access"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

  ingress_rules = [
    {
      description     = "[${split("_", each.key)[0]}] Allow SSH (22) from VPN security group"
      from_port       = 22
      to_port         = 22
      protocol        = "tcp"
      security_groups = [var.vpn_sg_id]
    }
  ]

  tags = {
    Project = var.project
    Env     = split("_", each.key)[0]
    Tier    = "network"
    Name    = "bizkit-sg-${split("_", each.key)[0]}-nat"
  }
}

module "nat_instances" {
  source = "../../modules/nat_instance"

  for_each = var.nat_instances

  name          = each.value.name
  ami_id        = each.value.ami_id
  instance_type = each.value.instance_type
  subnet_id     = each.value.subnet_id
  security_group_ids = (
    var.nat_sg_migration_mode == "legacy" ? each.value.security_group_ids :
    var.nat_sg_migration_mode == "dual" ? distinct(concat(each.value.security_group_ids, [local.new_nat_sg_ids[each.key]])) :
    distinct(concat(
      [for sg in each.value.security_group_ids : sg if sg != lookup(var.legacy_nat_security_group_ids, each.key, "")],
      [local.new_nat_sg_ids[each.key]]
    ))
  )
  key_name                    = each.value.key_name
  iam_instance_profile_name   = try(each.value.iam_instance_profile_name, null)
  associate_public_ip_address = try(each.value.associate_public_ip_address, true)
  source_dest_check           = try(each.value.source_dest_check, false)
  instance_tags = merge(
    {
      Project = var.project
    },
    try(each.value.instance_tags, {})
  )
  eip_tags = merge(
    {
      Project = var.project
    },
    try(each.value.eip_tags, {})
  )
}
