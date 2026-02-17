output "id" {
  description = "Application Load Balancer ID."
  value       = aws_lb.this.id
}

output "arn" {
  description = "Application Load Balancer ARN."
  value       = aws_lb.this.arn
}

output "dns_name" {
  description = "Application Load Balancer DNS name."
  value       = aws_lb.this.dns_name
}

output "zone_id" {
  description = "Application Load Balancer hosted zone ID."
  value       = aws_lb.this.zone_id
}

output "target_group_arns" {
  description = "Target group ARNs keyed by logical key."
  value       = { for k, v in aws_lb_target_group.this : k => v.arn }
}

output "listener_arns" {
  description = "Listener ARNs keyed by logical key."
  value       = { for k, v in aws_lb_listener.this : k => v.arn }
}

output "target_group_attachment_ids" {
  description = "Target group attachment IDs keyed by logical key."
  value       = { for k, v in aws_lb_target_group_attachment.this : k => v.id }
}
