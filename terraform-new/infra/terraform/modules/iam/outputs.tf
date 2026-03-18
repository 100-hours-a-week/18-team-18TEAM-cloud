output "role_name" {
  value       = aws_iam_role.this.name
  description = "IAM role name."
}

output "role_arn" {
  value       = aws_iam_role.this.arn
  description = "IAM role ARN."
}

output "instance_profile_name" {
  value       = try(aws_iam_instance_profile.this[0].name, null)
  description = "IAM instance profile name."
}
