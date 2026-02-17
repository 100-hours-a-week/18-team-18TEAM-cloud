resource "aws_route_table" "this" {
  vpc_id = var.vpc_id

  tags = merge(
    {
      Name      = var.name
      Project   = var.project
      Env       = var.env
      Tier      = var.tier
      ManagedBy = "terraform"
      Module    = "network"
    },
    var.tags
  )
}

resource "aws_route" "this" {
  for_each = {
    for idx, r in var.routes : tostring(idx) => r
  }

  route_table_id         = aws_route_table.this.id
  destination_cidr_block = each.value.cidr_block

  gateway_id           = each.value.target_type == "igw" ? var.igw_id : null
  nat_gateway_id       = each.value.target_type == "nat_gateway" ? try(each.value.target_id, null) : null
  network_interface_id = each.value.target_type == "eni" ? try(each.value.target_id, null) : null
}

resource "aws_route_table_association" "this" {
  for_each = toset(var.associate_subnet_ids)

  subnet_id      = each.value
  route_table_id = aws_route_table.this.id
}
