output "id" {
  description = "security group id"
  value       = aws_security_group.this.id
}

output "arn" {
  description = "security group arn"
  value       = aws_security_group.this.arn
}

output "name" {
  description = "security group name"
  value       = aws_security_group.this.name
}