variable "config" {
  type = object({
    name         = string
    scan_on_push = optional(bool)
    policy_path  = optional(string)
    tags         = optional(map(string))
    encryption_configuration = optional(object({
      encryption_type = string
      kms_arn         = optional(string)
    }))
  })
}
