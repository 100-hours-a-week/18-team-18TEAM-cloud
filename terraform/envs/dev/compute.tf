locals {
  legacy_primary_sg_ids = var.remove_legacy_sg ? [] : [
    module.ssh[0].id,
    module.webserver[0].id,
    module.monitor[0].id,
  ]

  new_primary_sg_ids = var.sg_migration_mode == "legacy" ? [] : [
    module.ssh_v2[0].id,
    module.webserver_v2[0].id,
    module.monitor_v2[0].id,
  ]

  computed_primary_sg_ids = var.remove_legacy_sg ? local.new_primary_sg_ids : (
    var.sg_migration_mode == "legacy" ? var.security_group_ids : (
      var.sg_migration_mode == "dual" ? distinct(concat(var.security_group_ids, local.new_primary_sg_ids)) : distinct(concat(
        [for sg in var.security_group_ids : sg if !contains(local.legacy_primary_sg_ids, sg)],
        local.new_primary_sg_ids
      ))
    )
  )

  metrics_legacy_ssh_sg_id = var.remove_legacy_sg ? null : module.ssh[0].id
  metrics_new_ssh_sg_id    = var.sg_migration_mode == "legacy" ? null : module.ssh_v2[0].id

  computed_metrics_sg_ids = var.remove_legacy_sg ? (
    local.metrics_new_ssh_sg_id == null ? var.metrics_security_group_ids : [local.metrics_new_ssh_sg_id]
    ) : (
    var.sg_migration_mode == "legacy" ? var.metrics_security_group_ids : (
      var.sg_migration_mode == "dual" ? distinct(concat(
        var.metrics_security_group_ids,
        local.metrics_new_ssh_sg_id == null ? [] : [local.metrics_new_ssh_sg_id]
        )) : distinct(concat(
        [for sg in var.metrics_security_group_ids : sg if local.metrics_legacy_ssh_sg_id == null || sg != local.metrics_legacy_ssh_sg_id],
        local.metrics_new_ssh_sg_id == null ? [] : [local.metrics_new_ssh_sg_id]
      ))
    )
  )
}

module "compute_single" {
  source = "../../modules/compute_single"

  project     = var.project
  env         = var.env
  name_suffix = var.name_suffix

  subnet_id                   = var.subnet_id
  security_group_ids          = local.computed_primary_sg_ids
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

module "compute_metrics" {
  count  = var.enable_metrics_instance ? 1 : 0
  source = "../../modules/compute_single"

  project     = var.project
  env         = var.env
  name_suffix = var.metrics_name_suffix

  subnet_id                   = var.metrics_subnet_id
  security_group_ids          = local.computed_metrics_sg_ids
  ami_id                      = var.metrics_ami_id
  instance_type               = var.metrics_instance_type
  key_name                    = var.metrics_key_name
  associate_public_ip_address = var.metrics_associate_public_ip_address

  create_instance_profile   = false
  iam_instance_profile_name = var.metrics_iam_instance_profile_name

  enable_ssm = false

  additional_iam_policy_arns = []
  create_eip                 = false

  tags = merge(var.tags, {
    Tier = "single-ec2"
  })
}
