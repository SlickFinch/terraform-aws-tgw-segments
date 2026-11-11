# Changelog

## v1.1.0

- Add the `spoke-routes` submodule. It creates one route per pair of spoke route table and destination CIDR, keyed by route table index, so a new VPC plans before its route table IDs exist.

## v1.0.0

- First release. Creates one Transit Gateway route table per segment, accepts spoke attachments, associates each with its segment and propagates it into every segment whose `reaches` list includes it. Accepters have `prevent_destroy`.
