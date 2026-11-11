# terraform-aws-tgw-segments

OpenTofu and Terraform module that splits an AWS Transit Gateway into segments. Each segment gets its own route table, and it learns routes only from the segments in its `reaches` list.
