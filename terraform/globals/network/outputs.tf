output "vpc_id" {
  value = aws_vpc.main.id
}

output "dev_public_subnet_ids" {
  value = [aws_subnet.dev_public_1.id]
}

output "dev_private_subnet_ids" {
  value = [aws_subnet.dev_private_1.id]
}

output "internet_gateway_id" {
    value = aws_internet_gateway.main.id
}