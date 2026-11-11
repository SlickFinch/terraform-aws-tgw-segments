# spoke-routes

Sends traffic for a list of CIDRs from a spoke VPC's route tables to a Transit Gateway. It creates one route per pair of route table and CIDR.

Route keys are `<route table index>/<cidr>`, so a new VPC plans cleanly before its route table IDs exist. Keep the order of `route_table_ids` stable: reordering the list replaces routes.

## Usage

```hcl
module "hub_routes" {
  source = "git::https://github.com/SlickFinch/terraform-aws-tgw-segments.git//modules/spoke-routes?ref=v1.1.0"

  transit_gateway_id = var.transit_gateway_id
  route_table_ids    = module.vpc.private_route_table_ids
  destination_cidrs  = ["10.20.0.0/16"]

  # Routes to a Transit Gateway fail until the attachment exists.
  depends_on = [module.tgw_attachment]
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.8.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_route.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_destination_cidrs"></a> [destination\_cidrs](#input\_destination\_cidrs) | IPv4 CIDRs to send through the Transit Gateway. | `list(string)` | n/a | yes |
| <a name="input_route_table_ids"></a> [route\_table\_ids](#input\_route\_table\_ids) | VPC route tables that get a route to each destination. Order matters: keys use the list index, so a new VPC can plan before its route table IDs exist. | `list(string)` | n/a | yes |
| <a name="input_transit_gateway_id"></a> [transit\_gateway\_id](#input\_transit\_gateway\_id) | ID of the Transit Gateway the routes point to. | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_route_keys"></a> [route\_keys](#output\_route\_keys) | Route keys, each <route table index>/<cidr>. |
<!-- END_TF_DOCS -->