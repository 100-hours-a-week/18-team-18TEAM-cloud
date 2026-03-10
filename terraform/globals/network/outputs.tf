output "vpc_id" {
  value = aws_vpc.main.id
}

output "dev_public_subnet_ids" {
  value = compact([
    try(aws_subnet.this["dev_public"].id, null),
  ])
}

output "dev_private_subnet_ids" {
  value = compact([
    try(aws_subnet.this["dev_app"].id, null),
    try(aws_subnet.this["dev_ops"].id, null),
  ])
}

output "internet_gateway_id" {
  value = aws_internet_gateway.main.id
}

output "shared_public_access_subnet_id" {
  value = try(aws_subnet.this["shared_public_access"].id, null)
}

output "shared_private_ops_subnet_id" {
  value = try(aws_subnet.this["shared_private_ops"].id, null)
}

output "prod_public_subnet_ids" {
  value = compact([
    try(aws_subnet.this["prod_public_a"].id, null),
    try(aws_subnet.this["prod_public_c"].id, null),
  ])
}

output "staging_public_subnet_ids" {
  value = compact([
    try(aws_subnet.this["staging_public_a"].id, null),
    try(aws_subnet.this["staging_public_c"].id, null),
  ])
}
