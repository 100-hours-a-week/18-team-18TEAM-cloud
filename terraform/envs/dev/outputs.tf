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
