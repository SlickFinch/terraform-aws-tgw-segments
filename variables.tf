variable "name" {
  description = "Prefix for the Name tag of every route table and accepter, for example acme-network-usw2-tgw."
  type        = string
}

variable "transit_gateway_id" {
  description = "ID of the Transit Gateway that owns the segment route tables."
  type        = string
}

variable "segments" {
  description = "Network segments. Each gets a route table that learns routes only from the segments in its reaches list."
  type = map(object({
    reaches = list(string)
  }))

  validation {
    condition     = alltrue(flatten([for s in values(var.segments) : [for r in s.reaches : contains(keys(var.segments), r)]]))
    error_message = "Every name in a segment's reaches list must be a key of segments."
  }
}

variable "attachments" {
  description = "Spoke VPC attachments to accept. The map key names the attachment and must not change; segment is a key of segments."
  type = map(object({
    attachment_id = string
    segment       = string
  }))
  default = {}

  validation {
    condition     = alltrue([for a in values(var.attachments) : contains(keys(var.segments), a.segment)])
    error_message = "Every attachment's segment must be a key of segments."
  }

  validation {
    condition     = alltrue([for a in values(var.attachments) : can(regex("^tgw-attach-[0-9a-f]{17}$", a.attachment_id))])
    error_message = "Every attachment_id must look like tgw-attach- followed by 17 hex characters."
  }
}

variable "tags" {
  description = "Tags for every resource the module creates."
  type        = map(string)
  default     = {}
}
