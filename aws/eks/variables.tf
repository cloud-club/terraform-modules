variable "config" {
  type = object({
    name        = string
    version = string
    vpc_id              = string
    alb_security_group_id = string
    access_entries = optional(list(object({
      name              = string
      principal_arn     = string
      kubernetes_groups = optional(list(string))
      type              = string
    })), [])
    access_cidrs = optional(list(string), ["0.0.0.0/0"])
    eks_cluster_role_arn = string
    eks_fargate_role_arn = string
    pod_identity_roles = optional(list(object({
      name                      = string
      role_arn                  = string
      service_account_namespace = string
      service_account_name      = string
    })), [])
    addons = optional(list(object({
      name                     = string
      service_account_role_arn = optional(string)
      config = optional(object({
        replicaCount = optional(number, null)
        computeType  = optional(string),
        resources = optional(object({
          limits = optional(object({
            cpu    = optional(string),
            memory = optional(string),
          }))
          requests = optional(object({
            cpu    = optional(string),
            memory = optional(string),
          }))
        }))
      }), null)
    })),
    [
    {
      name = "kube-proxy"
    },
    {
      name = "vpc-cni"
    },
    {
      name = "coredns"
      config = {
        computeType = "Fargate"
        replicaCount = 2
        resources = {
          requests = {
            cpu = "100m"
            memory = "256Mi"
          }
          limits = {
            cpu = "250m"
            memory = "512Mi"
          }
        }
      }
    },
    # {
    #   name = "aws-ebs-csi-driver"
    # },
    {
      name = "eks-pod-identity-agent"
    }
    ]
    )
    karpenter_node_role_name = string
    subnet_ids = list(string)
  })
}