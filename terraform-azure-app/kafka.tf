# terraform-azure-app/kafka.tf
# Kafka VM resources — uses var.ssh_key_name directly

resource "azurerm_public_ip" "kafka_ip" {
  count               = var.include_kafka == "yes" ? 1 : 0
  name                = "${var.owner}-${var.resource_name}-public-ip-kafka"
  location            = var.virtual_network_location
  resource_group_name = local.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.tags
}

resource "azurerm_network_interface" "kafka" {
  count               = var.include_kafka == "yes" ? 1 : 0
  name                = "${var.owner}-${var.resource_name}-ni-kafka"
  location            = var.virtual_network_location
  resource_group_name = local.resource_group_name
  tags                = local.tags

  ip_configuration {
    name                          = "network-interface-kafka-ip"
    subnet_id                     = azurerm_subnet.private[0].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.kafka_ip[0].id
  }
}

resource "azurerm_linux_virtual_machine" "kafka" {
  count               = var.include_kafka == "yes" && var.create_ec2_instances == "yes" ? 1 : 0
  name                = "${var.owner}-${var.resource_name}-vm-kafka"
  location            = var.virtual_network_location
  resource_group_name = local.resource_group_name
  size                = var.kafka_instance_type
  tags                = local.tags

  network_interface_ids = [azurerm_network_interface.kafka[0].id]

  admin_username                  = var.login_username
  disable_password_authentication = true
  admin_ssh_key {
    username   = var.login_username
    public_key = data.azurerm_ssh_public_key.ssh_key.public_key
  }

  source_image_reference {
    publisher = var.test_publisher
    offer     = var.test_offer
    sku       = var.test_sku
    version   = var.test_version
  }

  os_disk {
    name                 = "${var.owner}-${var.resource_name}-osdisk-kafka"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  boot_diagnostics {
    storage_account_uri = null
  }
}

