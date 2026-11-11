locals {
  # Keys are "<route table index>/<cidr>", so they are known before the route tables exist.
  routes = {
    for pair in setproduct(range(length(var.route_table_ids)), var.destination_cidrs) : "${pair[0]}/${pair[1]}" => {
      route_table_index = pair[0]
      cidr              = pair[1]
    }
  }
}

resource "aws_route" "this" {
  for_each = local.routes

  route_table_id         = var.route_table_ids[each.value.route_table_index]
  destination_cidr_block = each.value.cidr
  transit_gateway_id     = var.transit_gateway_id
}
