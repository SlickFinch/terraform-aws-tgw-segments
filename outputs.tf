output "route_table_ids" {
  description = "Segment route table IDs keyed by segment name."
  value       = { for k, v in aws_ec2_transit_gateway_route_table.this : k => v.id }
}

output "accepted_attachment_ids" {
  description = "Accepted attachment IDs keyed by attachment name."
  value       = { for k, v in aws_ec2_transit_gateway_vpc_attachment_accepter.this : k => v.id }
}

output "propagations" {
  description = "Propagations keyed by attachment/segment, each with the attachment and segment names."
  value       = local.propagations
}
