resource "aws_subnet" "this" {
  for_each = var.subnets

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr_block
  map_public_ip_on_launch = each.value.map_public_ip_on_launch
  availability_zone       = each.value.availability_zone

  tags = merge(
    {
      Name      = each.value.name
      Project   = var.project
      Env       = each.value.env
      Tier      = each.value.tier
      ManagedBy = "terraform"
      Module    = "network"
    },
    each.value.tags
  )
}
