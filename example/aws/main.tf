locals {
  config = yamldecode(file("./config.yaml"))
  irsa_list = flatten([
    for eks in local.config.eks : [
      for irsa in eks.irsa : merge(irsa, {
        cluster_name = eks.name
      })
    ]
  ])
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
  source   = "../../aws/irsa"
  for_each = { for irsa in local.irsa_list : irsa.name => irsa }
  config   = each.value
}
