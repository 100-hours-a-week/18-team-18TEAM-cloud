output "instance_id" {
  description = "NAT instance ID."
  value       = aws_instance.this.id
}

output "primary_network_interface_id" {
  description = "Primary network interface ID of the NAT instance."
  value       = aws_instance.this.primary_network_interface_id
}

output "private_ip" {
  description = "Private IP address of the NAT instance."
  value       = aws_instance.this.private_ip
}

output "eip_allocation_id" {
  description = "Elastic IP allocation ID."
  value       = aws_eip.this.id
}

output "eip_public_ip" {
  description = "Elastic IP public address."
  value       = aws_eip.this.public_ip
}

output "eip_association_id" {
  description = "Elastic IP association ID."
  value       = aws_eip_association.this.id
}
