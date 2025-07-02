resource "azurerm_network_security_group" "desktop_sg" {
    name                = "${var.owner}-${var.resource_name}-sg"
    location            = var.virtual_network_location
    resource_group_name = local.resource_group_name
    tags                = local.tags
}

resource "azurerm_network_security_rule" "desktop_rule" {
        name                       = "Desktop-TO-CRDB"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_address_prefix      = "${var.my_ip_address}/32"
        source_port_range          = "*"
        destination_port_ranges    = [22,26257,3000,8080,8081,8082,8083,8088,9021,9090,9092,9093,2181]
        destination_address_prefix = "*"
        resource_group_name        = local.resource_group_name
        network_security_group_name = azurerm_network_security_group.desktop_sg.name
}

resource "azurerm_network_security_rule" "allow_vnet_inbound_all_tcp" {
  name                        = "Allow-VNet-In-All-TCP"
  priority                    = 1000
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_address_prefix       = "VirtualNetwork"
  source_port_range           = "*"
  destination_address_prefix  = "VirtualNetwork"
  destination_port_ranges     = ["1-65535"]
  resource_group_name         = local.resource_group_name
  network_security_group_name = azurerm_network_security_group.desktop_sg.name
}


resource "azurerm_network_security_rule" "netskope_ip_ranges" {
    name                       = "Netskope-IP-Ranges"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_address_prefixes    = var.netskope_ips
    source_port_range          = "*"
    destination_port_ranges    = [22,26257,8080, 9021, 3000, 8083, 9092, 9093,]
    destination_address_prefix = "*"
    resource_group_name         = local.resource_group_name
    network_security_group_name = azurerm_network_security_group.desktop_sg.name
}

resource "azurerm_subnet_network_security_group_association" "desktop-access" {
  count                     = length(azurerm_subnet.private)
  subnet_id                 =  azurerm_subnet.private[count.index].id
  network_security_group_id = azurerm_network_security_group.desktop_sg.id
}

# 7) Now, anywhere you need a private‐subnet_id, you can use:
#     azurerm_subnet.private[0].id   (or [1], [2], ...)
#    And for a public one:
#     azurerm_subnet.public[0].id
