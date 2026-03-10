locals {
  resolved_route_tables = {
    for rt_key, rt in var.route_tables : rt_key => merge(rt, {
      routes = [
        for r in try(rt.routes, []) : merge(r, {
          target_id = (
            r.target_type == "eni" && try(r.nat_key, null) != null
            ? try(data.terraform_remote_state.nat.outputs.nat_eni_ids[r.nat_key], try(r.target_id, null))
            : try(r.target_id, null)
          )
        })
      ]
    })
  }
}

module "route_tables" {
  source = "../../modules/route_table"

  for_each = local.resolved_route_tables

  vpc_id  = aws_vpc.main.id
  igw_id  = aws_internet_gateway.main.id
  name    = each.value.name
  project = var.project
  env     = each.value.env
  tier    = each.value.tier
  tags    = each.value.tags
  routes  = each.value.routes

  associate_subnet_ids = [
    for _, assoc in var.route_table_associations : aws_subnet.this[assoc.subnet_key].id
    if assoc.route_table_key == each.key
  ]
}
