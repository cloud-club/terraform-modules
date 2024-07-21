variable "config" {
  type = object({
    account_id = string
    is_workload_identity = optional(bool, false)
    iam_binding = optional(list(object({
        name    = string
        role    = string
        members = list(string)
    })),[])
  })
}