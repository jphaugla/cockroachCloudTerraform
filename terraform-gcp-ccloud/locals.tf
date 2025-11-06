locals {
  # Regions list is only needed when you CREATE a cluster
  effective_regions = var.create_cluster ? [
    for r in var.gcp_region_list : {
      name       = r
      node_count = var.node_count  # node_count is ignored when importing
    }
  ] : []

  required_tags = {
    owner   = var.owner
    project = var.project_id
  }

  tags           = merge(var.resource_tags, local.required_tags)
  admin_username = "ec2-user"

  # Endpoints: from created resource OR from inputs when importing
  # For GCP PSC: use cluster-level private_endpoint_dns
  # crdb_private_endpoint_dns = var.create_cluster ? try(cockroach_cluster.advanced[0].private_endpoint_dns, "") : var.existing_crdb_private_endpoint_dns
  crdb_private_endpoint_dns_list = var.create_cluster ?  [for r in cockroach_cluster.advanced[0].regions : r.private_endpoint_dns] : var.existing_crdb_private_endpoint_dns_list
  crdb_public_endpoint_dns_list = var.create_cluster ?  [for r in cockroach_cluster.advanced[0].regions : r.sql_dns] : var.existing_crdb_public_endpoint_dns_list

  region_count   = length(local.crdb_public_endpoint_dns_list)
  default_region = var.gcp_region_list[0]
  cluster_name = "${var.owner}-${var.project_id}-adv-gcp"
}

