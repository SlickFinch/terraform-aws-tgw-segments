variable "transit_gateway_id" {
  description = "ID of the Transit Gateway the routes point to."
  type        = string
}

variable "route_table_ids" {
  description = "VPC route tables that get a route to each destination. Order matters: keys use the list index, so a new VPC can plan before its route table IDs exist."
  type        = list(string)
}

variable "destination_cidrs" {
  description = "IPv4 CIDRs to send through the Transit Gateway."
  type        = list(string)

  validation {
    condition     = alltrue([for c in var.destination_cidrs : can(cidrhost(c, 0))])
    error_message = "Every destination_cidrs entry must be an IPv4 CIDR."
  }
}
