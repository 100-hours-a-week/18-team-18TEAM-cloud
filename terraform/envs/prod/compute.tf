locals {
  legacy_primary_sg_ids = length(var.primary_legacy_sg_ids) > 0 ? var.primary_legacy_sg_ids : compact([
    try(module.ssh[0].id, null),
    try(module.webserver[0].id, null),
    try(module.monitor[0].id, null),
  ])

  new_primary_sg_ids = var.sg_migration_mode == "legacy" ? [] : [
    module.ssh_v2[0].id,
    module.webserver_v2[0].id,
    module.monitor_v2[0].id,
  ]

  computed_primary_sg_ids = var.remove_legacy_sg ? distinct(concat(
    [for sg in var.security_group_ids : sg if !contains(local.legacy_primary_sg_ids, sg)],
    local.new_primary_sg_ids
    )) : (
    var.sg_migration_mode == "legacy" ? var.security_group_ids : (
      var.sg_migration_mode == "dual" ? distinct(concat(var.security_group_ids, local.new_primary_sg_ids)) : distinct(concat(
        [for sg in var.security_group_ids : sg if !contains(local.legacy_primary_sg_ids, sg)],
        local.new_primary_sg_ids
      ))
    )
  )

  new_app_alb_sg_ids = var.alb_sg_migration_mode == "legacy" ? [] : [
    module.app_from_alb_v2[0].id,
  ]

  computed_security_group_ids = var.alb_sg_migration_mode == "legacy" ? local.computed_primary_sg_ids : (
    var.alb_sg_migration_mode == "dual" ? distinct(concat(local.computed_primary_sg_ids, local.new_app_alb_sg_ids)) : distinct(concat(
      [for sg in local.computed_primary_sg_ids : sg if !contains(var.app_alb_legacy_sg_ids, sg)],
      local.new_app_alb_sg_ids
    ))
  )
}

module "compute_single" {
  source = "../../modules/compute_single"

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

  tags = merge(var.tags, {
    Tier = "single-ec2"
  })
}
