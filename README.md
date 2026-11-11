# terraform-aws-tgw-segments

OpenTofu and Terraform module that splits an AWS Transit Gateway into segments. Each segment gets its own route table, and it learns routes only from the segments in its `reaches` list. The module also accepts spoke VPC attachments, associates each one with its segment's route table and propagates it into every segment that reaches it.

Use it on a Transit Gateway with auto-accept and the default route tables turned off, so that every attachment goes through a segment.

## Usage

Pin the module to a release tag:

```hcl
module "segments" {
  source = "git::https://github.com/SlickFinch/terraform-aws-tgw-segments.git?ref=v1.0.0"

  name               = "acme-network-usw2-tgw"
  transit_gateway_id = module.transit_gateway.ec2_transit_gateway_id

  segments = {
    shared = { reaches = ["dev", "prod"] }
    dev    = { reaches = ["shared"] }
    prod   = { reaches = ["shared"] }
  }

  attachments = {
    dev = { attachment_id = "tgw-attach-0123456789abcdef1", segment = "dev" }
  }
}
```

See [examples/complete](examples/complete).

## How segments work

- `segments` lists the segments. Each one gets a route table named `<name>-<segment>`.
- `reaches` lists the segments whose routes a segment's route table learns. In the example, `dev` and `prod` learn only `shared`, so dev and prod can't reach each other.
- `attachments` lists the spoke attachments to accept. Each one is associated with its own segment's route table and propagated into every segment whose `reaches` includes it.

The accepters have `prevent_destroy`, because destroying an accepter deletes the spoke's attachment. Never change an `attachments` key. To rename one, use a `moved` block.

## Testing

`tofu test` runs the tests in `tests/` with a mocked AWS provider, so it needs no credentials.

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
| [aws_ec2_transit_gateway_route_table.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table) | resource |
| [aws_ec2_transit_gateway_route_table_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_association) | resource |
| [aws_ec2_transit_gateway_route_table_propagation.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_propagation) | resource |
| [aws_ec2_transit_gateway_vpc_attachment_accepter.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_vpc_attachment_accepter) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_name"></a> [name](#input\_name) | Prefix for the Name tag of every route table and accepter, for example acme-network-usw2-tgw. | `string` | n/a | yes |
| <a name="input_segments"></a> [segments](#input\_segments) | Network segments. Each gets a route table that learns routes only from the segments in its reaches list. | <pre>map(object({<br/>    reaches = list(string)<br/>  }))</pre> | n/a | yes |
| <a name="input_transit_gateway_id"></a> [transit\_gateway\_id](#input\_transit\_gateway\_id) | ID of the Transit Gateway that owns the segment route tables. | `string` | n/a | yes |
| <a name="input_attachments"></a> [attachments](#input\_attachments) | Spoke VPC attachments to accept. The map key names the attachment and must not change; segment is a key of segments. | <pre>map(object({<br/>    attachment_id = string<br/>    segment       = string<br/>  }))</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags for every resource the module creates. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_accepted_attachment_ids"></a> [accepted\_attachment\_ids](#output\_accepted\_attachment\_ids) | Accepted attachment IDs keyed by attachment name. |
| <a name="output_propagations"></a> [propagations](#output\_propagations) | Propagations keyed by attachment/segment, each with the attachment and segment names. |
| <a name="output_route_table_ids"></a> [route\_table\_ids](#output\_route\_table\_ids) | Segment route table IDs keyed by segment name. |
<!-- END_TF_DOCS -->
