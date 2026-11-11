# Runs without AWS credentials: `tofu test` (or `terraform test`).

mock_provider "aws" {}

variables {
  name               = "example-tgw"
  transit_gateway_id = "tgw-0123456789abcdef0"
  segments = {
    shared = { reaches = ["dev", "prod"] }
    dev    = { reaches = ["shared"] }
    prod   = { reaches = ["shared"] }
  }
  attachments = {
    cicd = { attachment_id = "tgw-attach-0123456789abcdef0", segment = "shared" }
    dev  = { attachment_id = "tgw-attach-0123456789abcdef1", segment = "dev" }
  }
}

run "one_route_table_per_segment" {
  command = plan

  assert {
    condition     = length(aws_ec2_transit_gateway_route_table.this) == 3
    error_message = "Expected one route table per segment."
  }

  assert {
    condition     = aws_ec2_transit_gateway_route_table.this["dev"].tags["Name"] == "example-tgw-dev"
    error_message = "Route table Name tag must be <name>-<segment>."
  }
}

run "accepters_skip_default_route_tables" {
  command = plan

  assert {
    condition     = aws_ec2_transit_gateway_vpc_attachment_accepter.this["dev"].transit_gateway_default_route_table_association == false
    error_message = "Accepters must not use the default association route table."
  }

  assert {
    condition     = aws_ec2_transit_gateway_vpc_attachment_accepter.this["dev"].transit_gateway_default_route_table_propagation == false
    error_message = "Accepters must not use the default propagation route table."
  }
}

run "propagations_follow_reaches" {
  command = plan

  # shared is reached by dev and prod; dev is reached by shared only.
  assert {
    condition     = toset(keys(aws_ec2_transit_gateway_route_table_propagation.this)) == toset(["cicd/dev", "cicd/prod", "dev/shared"])
    error_message = "Propagations must follow the reaches lists."
  }
}

run "dev_and_prod_do_not_reach_each_other" {
  command = plan

  assert {
    condition     = !contains(keys(aws_ec2_transit_gateway_route_table_propagation.this), "dev/prod")
    error_message = "dev must not propagate into prod."
  }
}

run "rejects_unknown_reach" {
  command = plan

  variables {
    segments = {
      dev = { reaches = ["nowhere"] }
    }
    attachments = {}
  }

  expect_failures = [var.segments]
}

run "rejects_bad_attachment_id" {
  command = plan

  variables {
    attachments = {
      dev = { attachment_id = "attach-123", segment = "dev" }
    }
  }

  expect_failures = [var.attachments]
}
