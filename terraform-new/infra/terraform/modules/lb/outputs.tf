output "lb_arn" {
  value       = aws_lb.this.arn
  description = "Load balancer ARN."
}

output "dns_name" {
  value       = aws_lb.this.dns_name
  description = "Load balancer DNS name."
}

output "target_group_arn" {
  value       = aws_lb_target_group.this.arn
  description = "Target group ARN."
}
