variable "project_name" {
  type = string
  description = "The name of the project"
  default = "cloud-club"
}

variable "security_group" {
  type = object({
    vpc_id = string
    ingress_rules = optional(
        map(object({
            ingress_from_port = number
            ingress_to_port = number
            ingress_protocol = string
            self = optional(bool)
            cidr_blocks = optional(list(string))
            security_group_id = optional(string)
        })))
    egress_rules = optional(
        map(object({
            egress_from_port = number
            egress_to_port = number
            egress_protocol = string
            self = optional(bool)
            cidr_blocks = optional(list(string))
            security_group_id = optional(string)
        })))
  })
  default = {
    vpc_id = ""
  }
}