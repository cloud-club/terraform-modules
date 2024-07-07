locals {
  config = yamldecode(file("./config.yaml"))
}


module "parameter_store_plain" { 
    source = "../../aws/parameter-store/plain"
    for_each ={for store in  local.config.parameter_store.plain: store.name => store}
    config = each.value
}

module "parameter_store_secure" {
    source = "../../aws/parameter-store/secure"
    for_each ={for store in  local.config.parameter_store.secure: store.name => store}
    config = each.value
}