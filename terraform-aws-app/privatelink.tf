# PrivateLink wiring (disabled by default)
# All Cockroach-provider resources are skipped unless enable_privatelink = true

resource "cockroach_private_endpoint_services" "aws" {
  count      = var.enable_privatelink ? 1 : 0
  cluster_id = var.crdb_cluster_id
}

# Wait for the service to be registered and resolve its AWS service name
data "aws_vpc_endpoint_service" "crdb" {
  count        = var.enable_privatelink ? 1 : 0
  service_name = lookup(
    cockroach_private_endpoint_services.aws[0].services_map,
    var.aws_region,
    values(cockroach_private_endpoint_services.aws[0].services_map)[0],
  ).name

  depends_on = [cockroach_private_endpoint_services.aws]
}

# Create the Interface VPC Endpoint in your VPC
resource "aws_vpc_endpoint" "crdb" {
  count                = var.enable_privatelink ? 1 : 0
  vpc_id               = aws_vpc.main.id
  service_name         = data.aws_vpc_endpoint_service.crdb[0].service_name
  vpc_endpoint_type    = "Interface"
  subnet_ids           = aws_subnet.private_subnets[*].id
  security_group_ids   = [module.sg_application.security_group_id]
  private_dns_enabled  = var.enable_private_dns
}

# Only needed if you're using trusted owners
data "aws_caller_identity" "me" {
  count = var.enable_privatelink && var.use_trusted_owners ? 1 : 0
}

resource "cockroach_private_endpoint_trusted_owner" "aws_account" {
  count             = var.enable_privatelink && var.use_trusted_owners ? 1 : 0
  cluster_id        = var.crdb_cluster_id
  external_owner_id = data.aws_caller_identity.me[0].account_id
  type              = "AWS_ACCOUNT_ID"
}


# Establish the connection
resource "cockroach_private_endpoint_connection" "aws" {
  count = var.enable_privatelink ? 1 : 0
  depends_on = [
    cockroach_private_endpoint_trusted_owner.aws_account,
    aws_vpc_endpoint.crdb,
  ]

  cluster_id  = var.crdb_cluster_id
  endpoint_id = aws_vpc_endpoint.crdb[0].id
}

# (Removed) This lookup forces a provider call; omit it entirely.
# data "cockroach_cluster" "advanced" { ... }

