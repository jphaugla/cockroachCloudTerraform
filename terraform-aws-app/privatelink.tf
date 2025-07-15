# privatelink.tf

resource "cockroach_private_endpoint_services" "aws" {
  cluster_id = var.crdb_cluster_id
}

# 1) Wait for Cockroach to register the AWS PrivateLink service…
data "aws_vpc_endpoint_service" "crdb" {
  # This name comes from the Cockroach API
  service_name = lookup(
    cockroach_private_endpoint_services.aws.services_map,
    var.aws_region,
    values(cockroach_private_endpoint_services.aws.services_map)[0],
  ).name

  depends_on = [
    cockroach_private_endpoint_services.aws,
  ]
}

# 2) Then create the Interface VPC Endpoint against that service
resource "aws_vpc_endpoint" "crdb" {
  depends_on        = [ data.aws_vpc_endpoint_service.crdb ]

  vpc_id            = aws_vpc.main.id
  service_name      = data.aws_vpc_endpoint_service.crdb.service_name
  vpc_endpoint_type = "Interface"
  subnet_ids        = aws_subnet.private_subnets[*].id
  security_group_ids = [module.sg_application.security_group_id]
  private_dns_enabled = var.enable_private_dns
}

data "aws_caller_identity" "me" {}

resource "cockroach_private_endpoint_trusted_owner" "aws_account" {
  cluster_id        = var.crdb_cluster_id
  external_owner_id = data.aws_caller_identity.me.account_id
  type              = "AWS_ACCOUNT_ID"
}

resource "cockroach_private_endpoint_connection" "aws" {
  depends_on = [
    cockroach_private_endpoint_trusted_owner.aws_account,
    aws_vpc_endpoint.crdb,
  ]

  cluster_id  = var.crdb_cluster_id
  endpoint_id = aws_vpc_endpoint.crdb.id
}

# 4) (Optional) Look up the cluster’s internal DNS name now that PrivateLink is active
data "cockroach_cluster" "advanced" {
  id = var.crdb_cluster_id
}
