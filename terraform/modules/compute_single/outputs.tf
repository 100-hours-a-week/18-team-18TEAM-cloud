output "name_prefix" {
  description = "Computed name prefix in format {project}-{env}-{role}."
  value       = local.name_prefix
}

output "instance_id" {
  description = "ID of the managed EC2 instance."
  value       = aws_instance.this.id
}

output "private_ip" {
  description = "Private IPv4 address of the EC2 instance."
  value       = aws_instance.this.private_ip
}

output "public_ip" {
  description = "Public IPv4 address of the EC2 instance when assigned."
  value       = aws_instance.this.public_ip
}

output "eip_public_ip" {
  description = "Elastic IP address when create_eip is true, otherwise null."
  value       = try(aws_eip.this[0].public_ip, null)
}

output "effective_public_ip" {
  description = "Externally reachable IP: EIP if present, otherwise instance public IP."
  value       = var.create_eip ? try(aws_eip.this[0].public_ip, aws_instance.this.public_ip) : aws_instance.this.public_ip
}

output "iam_instance_profile_name" {
  description = "IAM instance profile attached to EC2 (created or provided)."
  value       = var.create_instance_profile ? try(aws_iam_instance_profile.instance_profile[0].name, null) : var.iam_instance_profile_name
}

output "iam_role_name" {
  description = "IAM role name created by this module, null when not created."
  value       = try(aws_iam_role.instance_role[0].name, null)
}
