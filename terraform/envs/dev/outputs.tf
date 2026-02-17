output "dev_instance_id" {
  value = module.compute_single.instance_id
}

output "dev_private_ip" {
  value = module.compute_single.private_ip
}

output "dev_public_ip" {
  value = module.compute_single.public_ip
}

output "dev_effective_public_ip" {
  value = module.compute_single.effective_public_ip
}

output "dev_iam_instance_profile_name" {
  value = module.compute_single.iam_instance_profile_name
}

output "dev_iam_role_name" {
  value = module.compute_single.iam_role_name
}

output "dev_metrics_instance_id" {
  value = try(module.compute_metrics[0].instance_id, null)
}

output "dev_metrics_private_ip" {
  value = try(module.compute_metrics[0].private_ip, null)
}

output "dev_metrics_public_ip" {
  value = try(module.compute_metrics[0].public_ip, null)
}

output "dev_sg_migration_mode" {
  value = var.sg_migration_mode
}

output "dev_legacy_primary_sg_ids" {
  value = var.remove_legacy_sg ? [] : [
    module.ssh[0].id,
    module.webserver[0].id,
    module.monitor[0].id,
  ]
}

output "dev_new_primary_sg_ids" {
  value = var.sg_migration_mode == "legacy" ? [] : [
    module.ssh_v2[0].id,
    module.webserver_v2[0].id,
    module.monitor_v2[0].id,
  ]
}
