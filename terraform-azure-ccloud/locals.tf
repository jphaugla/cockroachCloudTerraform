# locals.tf
locals {
  # Build one entry per region-string, each with the same node_count
  effective_regions = [
    for r in var.region_list : {
      name       = r
      node_count = var.node_count
    }
  ]
  required_tags = {
    owner   = var.owner
    project = var.project_name
  }

  tags           = merge(var.resource_tags, local.required_tags)
  admin_username = "adminuser"

  crdb_private_endpoint_dns_list = [
    for r in cockroach_cluster.advanced.regions : r.internal_dns
  ]
  crdb_public_endpoint_dns_list = [
    for r in cockroach_cluster.advanced.regions : r.sql_dns
  ]
  region_count = length(local.crdb_private_endpoint_dns_list)
}

