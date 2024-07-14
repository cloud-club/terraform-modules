provider "google" {
  project = "project-id"
  region  = "asia-northeast3"
}

locals {
  config = yamldecode(file("config.yaml"))
  # templatefile_decryped_secrets ={for file in local.config.template_files : file.path => {
  #   for key, value in  lookup(file, "secrets", {}) : key => sensitive(value)
  # } }
  # template_files = [for file in local.config.template_files : templatefile("assets/${file.path}", merge(file.vars, local.templatefile_decryped_secrets["${file.path}"]))]
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
