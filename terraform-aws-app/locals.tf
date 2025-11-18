# locals.tf
locals {
  tags = merge(var.resource_tags, local.required_tags)

  required_tags = {
    owner   = var.owner
    project = var.project_name
  }

  admin_username = "ec2-user"
  bucket_name = "${var.owner}-${var.project_name}-${var.aws_region}-for-molt-bucket"
  # create 6 subnets: 3 for public subnets, 3 for private subnets
  subnet_list         = cidrsubnets(var.cidr, 3, 3, 3, 3, 3, 3)
  private_subnet_list = chunklist(local.subnet_list, 3)[0]
  public_subnet_list  = chunklist(local.subnet_list, 3)[1]

  # maximum AZs we want to consume
  desired_az_count = 3
  # strip scheme and any trailing slash
  _server_no_scheme = replace(replace(var.cockroach_server, "https://", ""), "http://", "")
  crdb_cloud_url    = trim(local._server_no_scheme, "/")

  # how many AZ names are actually returned here?
  actual_az_count = length(data.aws_availability_zones.available.names)

  # slice_end = min(actual_az_count, desired_az_count)
  slice_end = local.actual_az_count < local.desired_az_count ? local.actual_az_count : local.desired_az_count

  availability_zone_list = slice(
    data.aws_availability_zones.available.names,
    0,
    local.slice_end
  )

  # Safe even when count = 0 (no instance) — returns empty string
  # If you prefer, you can use try(...) instead of length(...):
  # kafka_private_ip = var.include_kafka == "yes" ? try(aws_instance.kafka[0].private_ip, "") : ""
  kafka_private_ip = var.include_kafka == "yes" && length(aws_instance.kafka) > 0 ? aws_instance.kafka[0].private_ip : ""
  app_private_ip = var.include_app == "yes" && length(aws_instance.app) > 0 ? aws_instance.app[0].private_ip : ""
}

data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}
