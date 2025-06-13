# privatelink.tf

resource "cockroach_private_endpoint_services" "aws" {
  cluster_id = cockroach_cluster.advanced.id
}

resource "aws_vpc_endpoint" "crdb" {
  vpc_id            = aws_vpc.main.id
  service_name      = cockroach_private_endpoint_services.aws.services_map[var.aws_region].name
  vpc_endpoint_type = "Interface"
  subnet_ids        = aws_subnet.private_subnets[*].id
  security_group_ids = [module.sg_application.security_group_id]

  # (Optional) Enable private DNS so your EC2s can resolve the cluster host by its normal hostname
  # private_dns_enabled = true
}

data "aws_caller_identity" "me" {}

resource "cockroach_private_endpoint_trusted_owner" "aws_account" {
  cluster_id        = cockroach_cluster.advanced.id
  external_owner_id = data.aws_caller_identity.me.account_id
  type              = "AWS_ACCOUNT_ID"
}

resource "cockroach_private_endpoint_connection" "aws" {
  depends_on = [cockroach_private_endpoint_trusted_owner.aws_account]
  cluster_id  = cockroach_cluster.advanced.id
  endpoint_id = aws_vpc_endpoint.crdb.id
}
# → this calls the Cloud API to “add” your VPCE to the cluster’s PrivateLink allowlist :contentReference[oaicite:2]{index=2}

# 4) (Optional) Look up the cluster’s internal DNS name now that PrivateLink is active
data "cockroach_cluster" "advanced" {
  id = cockroach_cluster.advanced.id
}
