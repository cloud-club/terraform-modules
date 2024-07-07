variable "config" {
  type = object({
    name             = string
    description      = optional(string)
    value            = string
    key_id           = optional(string)
    private_key_path = optional(string)
  })
}
