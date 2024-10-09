variable "config" {
  type = object({
    account_id = string
    workflow_identity = object({
      enable = optional(bool, false)
      service_account = optional(string, "")
      namespace = optional(string, "")
    })
    iam_binding = optional(list(object({
        name    = string
        role    = string
    })),[])
  })
}


variable "project_id" {
  type = string
}