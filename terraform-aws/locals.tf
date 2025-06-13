# locals.tf
locals {
  effective_regions = length(var.regions) > 0 ? var.regions : [
    {
      name       = var.aws_region
      node_count = var.node_count
    }
  ]
  required_tags = {
    owner       = var.owner,
    project     = var.project_name,
  }
  tags = merge(var.resource_tags, local.required_tags)
  admin_username = "ec2-user"
  # create 6 subnets: 3 for public subnets, 3 for private subnets
  subnet_list = cidrsubnets(var.cidr,3,3,3,3,3,3)
  private_subnet_list = chunklist(local.subnet_list,3)[0]
  public_subnet_list  = chunklist(local.subnet_list,3)[1]
 # maximum AZs we want to consume
  desired_az_count = 3

  # how many AZ names are actually returned here?
  actual_az_count = length(data.aws_availability_zones.available.names)

  # slice_end = min(actual_az_count, desired_az_count)
  slice_end = (
    local.actual_az_count < local.desired_az_count
  ) ? local.actual_az_count : local.desired_az_count

  availability_zone_list = slice(
    data.aws_availability_zones.available.names,
    0,
    local.slice_end
  )
}

data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

