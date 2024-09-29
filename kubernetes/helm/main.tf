locals {
  templatefile_decrypted_secrets = { for release in var.config : "${release.namespace}/${release.name}" => {
    for key, value in lookup(release.file, "secrets", {}) : key => sensitive(rsadecrypt(value, file("${var.encrypt_file_path}")))
  } }
}

resource "helm_release" "this" {
  for_each     = { for release in var.config : "${release.namespace}/${release.name}" => release }
  namespace    = each.value.namespace
  name         = each.value.name
  repository   = each.value.repository
  chart        = each.value.chart
  version      = each.value.version
  reuse_values = true
  values = each.value.file != null ? [templatefile(
    each.value.file.path, 
    merge(lookup(each.value.file, "vars", {}), local.templatefile_decrypted_secrets["${each.value.namespace}/${each.value.name}"]))] : []
  dynamic "set" {
    for_each = lookup(each.value, "set_values", {})
    content {
      name  = set.key
      value = set.value
    }
  }
}