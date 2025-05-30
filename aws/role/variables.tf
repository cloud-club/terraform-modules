variable "config" {
  description = "roles"
  type = object({
    name = string
    assume_role_policy_file = string
    inline_policies = optional(list(object({
      name = string
      policy_file = string
    })), [])
    policy_arns = optional(list(string),[])
  })
}