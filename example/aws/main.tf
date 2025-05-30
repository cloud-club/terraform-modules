locals {
  config = yamldecode(file("./config.yaml"))
  security_groups = flatten([
    for vpc in local.config.vpc : [
      for sg in vpc.security_groups : merge(sg, {
        vpc_id = module.vpc[vpc.name].vpc_id
      })
    ]
  ])

  eks = [for eks in local.config.eks : merge(eks, {
    vpc_id = module.vpc[eks.vpc].vpc_id
    subnet_ids = [for subnet in eks.subnet_names : module.vpc[eks.vpc].subnets[subnet]]
    alb_security_group_id = module.security_group[eks.alb_security_group_name].id
    eks_cluster_role_arn = module.iam_role[eks.eks_cluster_role_name].role_arn
    eks_fargate_role_arn = module.iam_role[eks.eks_fargate_role_name].role_arn
    pod_identity_roles = [for role in eks.pod_identity_roles : merge(role, {
      role_arn = module.iam_role[role.role_name].role_arn
    })]
    access_entries = [for entry in eks.access_entries : merge(entry, {
      principal_arn = module.iam_role[entry.role_name].role_arn
    })]
  })]
}

module "vpc" {
  source = "../../aws/vpc"
  for_each = { for vpc in local.config.vpc : vpc.name => vpc }
  config = each.value
}

module "security_group" {
  source = "../../aws/security-group"
  for_each = { for sg in local.security_groups : sg.name => sg }
  config = each.value
  depends_on = [ module.vpc ]
}

module "iam_role" {
  source = "../../aws/role"
  for_each = { for role in local.config.roles : role.name => role }
  config   = each.value
}

module "eks" {
  source = "../../aws/eks"
  for_each = { for eks in local.eks : eks.name => eks }
  config = each.value
  depends_on = [ module.vpc, module.security_group, module.iam_role ]
}

module "parameter_store_plain" {
  source   = "../../aws/parameter-store/plain"
  for_each = { for store in local.config.parameter_store.plain : store.name => store }
  config   = each.value
}

module "parameter_store_secure" {
  source   = "../../aws/parameter-store/secure"
  for_each = { for store in local.config.parameter_store.secure : store.name => store }
  config   = each.value
}

module "oidc" {
  source     = "../../aws/oidc"
  for_each   = { for oidc in local.config.oidc : oidc.name => oidc.issuer_url }
  issuer_url = each.value
}

module "ecr" {
  source   = "../../aws/ecr"
  for_each = { for ecr in local.config.ecr : ecr.name => ecr }
  config   = each.value
}

module "irsa" {
  source = "../../aws/irsa"
  for_each = { for irsa in local.config.irsa : irsa.name => irsa }
  config = merge(each.value, {
    eks_oidc_arn = module.eks[each.value.eks_name].eks_oidc_arn
    eks_oidc_issuer = module.eks[each.value.eks_name].eks_oidc_issuer
  })
  depends_on = [ module.eks ]
}