provider "aws" {
  region = "us-west-2"
}

module "transit_gateway" {
  source  = "terraform-aws-modules/transit-gateway/aws"
  version = "~> 3.3"

  name                                   = "acme-network-usw2-tgw"
  enable_auto_accept_shared_attachments  = false
  enable_default_route_table_association = false
  enable_default_route_table_propagation = false
  create_tgw_routes                      = false
  share_tgw                              = false
}

module "segments" {
  source = "../.."

  name               = "acme-network-usw2-tgw"
  transit_gateway_id = module.transit_gateway.ec2_transit_gateway_id

  segments = {
    shared = { reaches = ["dev", "prod"] }
    dev    = { reaches = ["shared"] }
    prod   = { reaches = ["shared"] }
  }

  # Spoke stacks create the attachments; add each one here to accept it.
  attachments = {
    dev = { attachment_id = "tgw-attach-0123456789abcdef1", segment = "dev" }
  }
}

output "route_table_ids" {
  description = "Segment route table IDs."
  value       = module.segments.route_table_ids
}

# In the spoke stack: route the spoke's private subnets to shared through the Transit Gateway.
module "spoke_routes" {
  source = "../../modules/spoke-routes"

  transit_gateway_id = module.transit_gateway.ec2_transit_gateway_id
  route_table_ids    = ["rtb-0123456789abcdef0"]
  destination_cidrs  = ["10.20.0.0/16"]
}
