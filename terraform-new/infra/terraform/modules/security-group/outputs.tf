output "id" {
  value       = aws_security_group.this.id
  description = "Security group ID."
}

output "arn" {
  value       = aws_security_group.this.arn
  description = "Security group ARN."
}
