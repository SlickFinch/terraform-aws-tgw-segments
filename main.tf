locals {
  # One propagation per attachment and per segment whose reaches list includes the attachment's segment.
  propagations = merge([
    for att_key, att in var.attachments : {
      for seg_key, seg in var.segments : "${att_key}/${seg_key}" => {
        attachment = att_key
        segment    = seg_key
      } if contains(seg.reaches, att.segment)
    }
  ]...)
}

resource "aws_ec2_transit_gateway_route_table" "this" {
  for_each = var.segments

  transit_gateway_id = var.transit_gateway_id

  tags = merge(var.tags, {
    Name    = "${var.name}-${each.key}"
    Segment = each.key
  })
}

resource "aws_ec2_transit_gateway_vpc_attachment_accepter" "this" {
  for_each = var.attachments

  transit_gateway_attachment_id                   = each.value.attachment_id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = merge(var.tags, {
    Name    = "${var.name}-${each.key}"
    Segment = each.value.segment
  })

  # Destroying the accepter deletes the spoke's attachment; rename keys with a moved block.
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "this" {
  for_each = var.attachments

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment_accepter.this[each.key].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this[each.value.segment].id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "this" {
  for_each = local.propagations

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment_accepter.this[each.value.attachment].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this[each.value.segment].id
}
