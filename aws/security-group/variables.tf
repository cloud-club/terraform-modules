variable "config" {
  type = object({
    name   = string
    vpc_id = string
    tags   = optional(map(string))
    ingress_rules = optional(map(object({
      ingress_from_port = number
      ingress_to_port   = number
      ingress_protocol  = string
      self              = optional(bool)
      cidr_blocks       = optional(list(string))
      security_group_id = optional(string)
    })))
    egress_rules = optional(map(object({
      egress_from_port  = number
      egress_to_port    = number
      egress_protocol   = string
      self              = optional(bool)
      cidr_blocks       = optional(list(string))
      security_group_id = optional(string)
    })))
  })
}
