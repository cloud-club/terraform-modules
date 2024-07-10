locals {
  config = yamldecode(file("config.yaml"))
  templatefile_decryped_secrets ={for file in local.config.template_files : file.path => {
    for key, value in  lookup(file, "secrets", {}) : key => sensitive(value)
  } }
  template_files = [for file in local.config.template_files : templatefile("assets/${file.path}", merge(file.vars, local.templatefile_decryped_secrets["${file.path}"]))]
}


module "vpc" {
    for_each = { for vpc in local.config.vpc : vpc.name => vpc}
  source = "../../gcp/vpc"
  config = each.value
}

output "template_files" {
  value = local.template_files
  sensitive = true
}

output "vpc_ids" {
  value = [for vpc in module.vpc : vpc.vpc_id]
}

output "subnets" {
  value = [for vpc in module.vpc : vpc.subnets]
}
