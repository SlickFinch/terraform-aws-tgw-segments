# Runs without AWS credentials: `tofu test` (or `terraform test`).

mock_provider "aws" {}

variables {
  transit_gateway_id = "tgw-0123456789abcdef0"
  route_table_ids    = ["rtb-0123456789abcdef0", "rtb-0123456789abcdef1"]
  destination_cidrs  = ["10.30.0.0/16", "10.40.0.0/16"]
}

run "one_route_per_table_and_cidr" {
  command = plan

  module {
    source = "./modules/spoke-routes"
  }

  assert {
    condition     = toset(keys(aws_route.this)) == toset(["0/10.30.0.0/16", "0/10.40.0.0/16", "1/10.30.0.0/16", "1/10.40.0.0/16"])
    error_message = "Expected one route per pair of route table index and CIDR."
  }

  assert {
    condition     = aws_route.this["1/10.40.0.0/16"].route_table_id == "rtb-0123456789abcdef1"
    error_message = "A route must use the route table at its index."
  }

  assert {
    condition     = aws_route.this["0/10.30.0.0/16"].transit_gateway_id == "tgw-0123456789abcdef0"
    error_message = "Routes must point to the Transit Gateway."
  }
}

run "rejects_bad_cidr" {
  command = plan

  module {
    source = "./modules/spoke-routes"
  }

  variables {
    destination_cidrs = ["10.30.0.0"]
  }

  expect_failures = [var.destination_cidrs]
}
