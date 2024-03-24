variable "repositry_name" {
  type = string
  default = "demo"
}

variable "scan_on_push" {
  type    = bool
  default = false
}

variable "tags" {
  type = list(object({
    name = string
    environment = string
  }))
  default = []
}


variable "encryption_configuration" {
  type = list(object({
    encryption_type = string
    kms_key          = string
  }))
  default = []
}


variable "policy_path" {
  type = string
  default = "policy.json"
}
