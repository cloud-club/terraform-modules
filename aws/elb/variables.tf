variable "config" {
  type = object({
    name = string
    internal = optional(bool, false)
    load_balancer_type = optional(string, "network")
    security_groups = optional(list(string), [])
    subnets = optional(list(string), [])
    port = optional(number, 80)
    protocol = optional(string, "HTTP")
    default_action_type = optional(string, "forward")
    target_type = optional(string, "instance")
    vpc_id = string
    target_group_attachments = optional(list(object({
      name = string
      target_id = string
      port = number
    })), [])
  })
}