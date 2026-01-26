output "name_prefix" {
  description = "리소스 이름 공통 접두사"
  value       = local.name_prefix
}

output "instance_id" {
  description = "EC2 Instance ID"
  value       = aws_instance.this.id
}

output "private_ip" {
  description = "EC2 Private IP"
  value       = aws_instance.this.private_ip
}

output "public_ip" {
  description = "EC2 Public IP (associate_public_ip_address=true인 경우)"
  value       = aws_instance.this.public_ip
}

output "eip_public_ip" {
  description = "EIP Public IP (create_eip=false면 null)"
  value       = try(aws_eip.this[0].public_ip, null)
}

output "effective_public_ip" {
  description = "외부에서 실제로 바라볼 IP: EIP가 있으면 EIP, 아니면 instance public ip"
  value       = var.create_eip ? try(aws_eip.this[0].public_ip, aws_instance.this.public_ip) : aws_instance.this.public_ip
}

output "iam_instance_profile_name" {
  description = "EC2에 연결된 Instance Profile 이름(생성 or 주입)"
  value       = var.create_instance_profile ? try(aws_iam_instance_profile.instance_profile[0].name, null) : var.iam_instance_profile_name
}

output "iam_role_name" {
  description = "모듈에서 생성한 IAM Role 이름(create_instance_profile=false면 null)"
  value       = try(aws_iam_role.instance_role[0].name, null)
}
