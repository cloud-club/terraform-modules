variable "bucket_name" {
    description = "The name of the S3 bucket"
    type        = string
}

# variable "bucket_acl" {
#     description = "The ACL for the S3 bucket"
#     type        = string
#     default     = "private"
# }

variable "public_access_block" {
  description = "value to block public access"
    type        = bool
    default     = false
}

variable "enable_versioning" {
    description = "Enable versioning for the S3 bucket"
    type        = bool
    default     = false
}

variable "cors_policy" {
  description = "cors policy for the bucket"
  type = list(object({
    allowed_headers = optional(list(string))
    allowed_methods = list(string)
    allowed_origins = list(string)
    expose_headers  = optional(list(string))
  }))
    default = [
    {
      allowed_headers = ["*"]
      allowed_methods = ["GET","POST","PUT"]
      allowed_origins = ["*"]
      expose_headers  = []
    }
    ]
}

variable "s3_policy_statements" {
  description = "List of policy statements for the S3 bucket"
  type = list(object({
    actions    = list(string)
    resources  = list(string)
    effect     = string
    principals = optional(list(object({
      type        = string
      identifiers = list(string)
    })))
    condition = optional(list(object({
      test        = string
      variable = string
      values     = list(string)
    })))
  }))
  default = []
}