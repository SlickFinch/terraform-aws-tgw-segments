# Complete example

A Transit Gateway with three segments: shared, dev and prod. Dev and prod reach shared only.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.8.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_segments"></a> [segments](#module\_segments) | ../.. | n/a |
| <a name="module_spoke_routes"></a> [spoke\_routes](#module\_spoke\_routes) | ../../modules/spoke-routes | n/a |
| <a name="module_transit_gateway"></a> [transit\_gateway](#module\_transit\_gateway) | terraform-aws-modules/transit-gateway/aws | ~> 3.3 |

## Resources

No resources.

## Inputs

No inputs.

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_route_table_ids"></a> [route\_table\_ids](#output\_route\_table\_ids) | Segment route table IDs. |
<!-- END_TF_DOCS -->
