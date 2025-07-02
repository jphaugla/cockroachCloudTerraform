locals {
  subnet_list = cidrsubnets(var.virtual_network_cidr,3,3,3,3,3,3)
  private_subnet_list = chunklist(local.subnet_list,3)[0]
  public_subnet_list  = chunklist(local.subnet_list,3)[1]
}
# 1) Your VNet
resource "azurerm_virtual_network" "vm01" {
  name                = "${var.owner}-${var.resource_name}-network"
  location            = var.virtual_network_location
  resource_group_name = local.resource_group_name
  address_space       = [var.virtual_network_cidr]
  tags                = local.tags
}

# 2) Private subnets
resource "azurerm_subnet" "private" {
  count                = length(local.private_subnet_list)
  name                 = "${var.owner}-${var.resource_name}-private-${count.index}"
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.vm01.name
  address_prefixes     = [ local.private_subnet_list[count.index] ]
  lifecycle {
    # ignore ANY drift on this subnet so TF never tries to touch the policy
    ignore_changes = all
  }
}

# 3) Public subnets
resource "azurerm_subnet" "public" {
  count                = length(local.public_subnet_list)
  name                 = "${var.owner}-${var.resource_name}-public-${count.index}"
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.vm01.name
  address_prefixes     = [ local.public_subnet_list[count.index] ]
}

# 7) Now, anywhere you need a private‐subnet_id, you can use:
#     azurerm_subnet.private[0].id   (or [1], [2], ...)
#    And for a public one:
#     azurerm_subnet.public[0].id
