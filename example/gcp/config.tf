provider "google" {
  project = "project-id"
  region  = "asia-northeast3"
}

locals {
  project_id = "project-id"
  config = yamldecode(file("config.yaml"))
  gke = [for gke in local.config.gke :
    merge(gke,
      {
        network = module.vpc["${gke.network_name}"].name
        subnet = module.vpc["${gke.network_name}"].subnets["${gke.subnetwork_name}"]
      }
  )]
  firewall_rules = [for rule in local.config.firewall_rules :
    merge(rule,
      {
        network = module.vpc["${rule.network_name}"].name
      }
  )]
  loadbalancers = [for lb in local.config.loadbalancers :
    merge(lb,
      {
        ssl_id = module.ssl["${lb.ssl_name}"].id
      }
  )]
}
