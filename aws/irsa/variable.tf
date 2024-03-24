variable "name" {
  type = string
default = "aws-sa-role"
}

variable "policy_arns" {
  type = list(string)
  default = []
}

variable "cluster_name" {
  type = string
  default = "demo"
}

variable "eks_issuer_url" {
  type = string
  default = ""
}

variable "service_account" {
  type = object({
    namespace = string
    name      = string
  })
  default = {
    namespace = "kube-system"
    name      = "aws-sa"
  }
}

