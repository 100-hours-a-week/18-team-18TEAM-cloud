module "ops_sg_v2" {
  count  = var.ops_sg_migration_mode == "legacy" ? 0 : 1
  source = "../../../modules/security_group"

  name        = "bizkit-sg-shared-ops"
  description = "[shared] Security group for shared operations and monitoring access"
  vpc_id      = var.vpc_id

  ingress_rules = [
    {
      description     = "[shared] Allow SSH (22) from VPN security group"
      from_port       = 22
      to_port         = 22
      protocol        = "tcp"
      security_groups = [var.vpn_sg_id]
    },
  ]

  tags = {
    Project = var.project
    Env     = var.env
    Tier    = "operations"
    Name    = "bizkit-sg-shared-ops"
  }
}

locals {
  new_ops_sg_ids = var.ops_sg_migration_mode == "legacy" ? [] : [module.ops_sg_v2[0].id]

  computed_security_group_ids = var.ops_sg_migration_mode == "legacy" ? var.security_group_ids : (
    var.ops_sg_migration_mode == "dual" ? distinct(concat(var.security_group_ids, local.new_ops_sg_ids)) : distinct(concat(
      [for sg in var.security_group_ids : sg if !contains(var.ops_legacy_sg_ids, sg)],
      local.new_ops_sg_ids
    ))
  )
}

module "compute_single" {
  source = "../../../modules/compute_single"

  project     = var.project
  env         = var.env
  name_suffix = var.name_suffix

  subnet_id                   = var.subnet_id
  security_group_ids          = local.computed_security_group_ids
  ami_id                      = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  associate_public_ip_address = var.associate_public_ip_address

  create_instance_profile   = false
  iam_instance_profile_name = var.iam_instance_profile_name

  enable_ssm = false

  additional_iam_policy_arns = []
  create_eip                 = false

  tags = merge(
    {
      Tier = "operations"
    },
    var.tags
  )
}
