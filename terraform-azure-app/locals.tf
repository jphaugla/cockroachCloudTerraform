# locals.tf
locals {
  app_zones = ["1", "2", "3"]
  required_tags = {
    owner       = var.owner,
  }
  tags = merge(var.resource_tags, local.required_tags)
  subnet_list = cidrsubnets(var.virtual_network_cidr,3,3,3,3,3,3)
  private_subnet_list = chunklist(local.subnet_list,3)[0]
  public_subnet_list  = chunklist(local.subnet_list,3)[1]
  bucket_name = "${var.owner}-${var.resource_name}-${var.virtual_network_location}-molt-bucket"
  kafka_private_ip = var.include_kafka == "yes" && length(azurerm_linux_virtual_machine.kafka) > 0 ? azurerm_linux_virtual_machine.kafka[0].private_ip_address : ""
  sql_user_password = "${var.sql_user_password}!"
}
