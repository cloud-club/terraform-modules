variable "config" {
  type = list(object({
    name        = string
    description = optional(string)
    type        = string
    data        = string
    key_id      = optional(string)
  }))
  default = []
}

variable "private_key_path" {
  type = string
  default = "/opt/private_key.pem"
}