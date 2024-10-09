module "vpc" {
  for_each = { for vpc in local.config.vpc : vpc.name => vpc }
  source   = "../../gcp/vpc"
  config   = each.value
}

module "firewall" {
  for_each = { for rule in local.firewall_rules : rule.name => rule }
  source   = "../../gcp/firewall"
  config   = each.value
  depends_on = [ module.vpc ]
}

module "gke" {
  for_each = { for gke in local.gke : gke.name => gke }
  source   = "../../gcp/gke"
  config   = each.value
  depends_on = [ module.vpc, local.gke ]
}


module "ssl"{
  for_each = { for ssl in local.config.ssl : ssl.name => ssl }
  source   = "../../gcp/ssl"
  config   = each.value
}

# module "load_balancer" {
#   for_each = { for lb in local.loadbalancers : lb.name => lb }
#   source   = "../../gcp/loadbalancer"
#   config   = each.value
#   depends_on = [ module.vpc, module.gke]
# }


module "sa" {
  for_each = { for sa in local.config.service_accounts : sa.account_id => sa }
  source   = "../../gcp/service-account"
  config   = each.value
  project_id = local.project_id
}

# module "gcs"{
#   for_each = { for gcs in local.config.gcs : gcs.name => gcs }
#   source   = "../../gcp/gcs"
#   config   = each.value
# }