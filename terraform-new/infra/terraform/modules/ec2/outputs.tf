output "instance_ids" {
  value       = aws_instance.this[*].id
  description = "Created EC2 instance IDs."
}

output "private_ips" {
  value       = aws_instance.this[*].private_ip
  description = "Private IPs of the created instances."
}

output "instance_names" {
  value       = aws_instance.this[*].tags.Name
  description = "Names of the created instances."
}
