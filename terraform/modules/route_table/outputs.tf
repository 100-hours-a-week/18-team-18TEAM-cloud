output "id" {
  value = aws_route_table.this.id
}

output "association_ids" {
  value = values(aws_route_table_association.this)[*].id
}
