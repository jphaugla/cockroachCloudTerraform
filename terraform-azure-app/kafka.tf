# kafka.tf
# Public IP (kept Basic/Dynamic per your snippet; switch to Standard/Static if needed)
resource "azurerm_public_ip" "kafka-ip" {
  count               = var.include_kafka == "yes" ? 1 : 0
  name                = "${var.owner}-${var.resource_name}-public-ip-kafka"
  location            = var.virtual_network_location
  resource_group_name = local.resource_group_name
  allocation_method   = "Dynamic"
  sku                 = "Basic"
  tags                = local.tags
}

# NIC — use the same private subnet set you use for app nodes
resource "azurerm_network_interface" "kafka" {
  count               = var.include_kafka == "yes" ? 1 : 0
  name                = "${var.owner}-${var.resource_name}-ni-kafka"
  location            = var.virtual_network_location
  resource_group_name = local.resource_group_name
  tags                = local.tags

  ip_configuration {
    name                          = "network-interface-kafka-ip"
    # If you want the first private subnet, mirror your app pattern:
    subnet_id                     = azurerm_subnet.private[0].id
    # If Kafka should follow app node distribution, you could also pick by index 0 safely
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.kafka-ip[0].id
  }
}

# Source image variables (rename hyphenated vars -> underscores in your variables.tf)
# variable "test_publisher" {}
# variable "test_offer" {}
# variable "test_sku" {}
# variable "test_version" {}

resource "azurerm_linux_virtual_machine" "kafka" {
  count               = var.include_kafka == "yes" && var.create_ec2_instances == "yes" ? 1 : 0
  name                = "${var.owner}-${var.resource_name}-vm-kafka"
  location            = var.virtual_network_location
  resource_group_name = local.resource_group_name
  size                = var.kafka_instance_type
  tags                = local.tags

  network_interface_ids = [azurerm_network_interface.kafka[0].id]

  # Yes, admin_username is still required alongside admin_ssh_key
  admin_username                  = var.login_username
  disable_password_authentication = true

  admin_ssh_key {
    # Known provider quirk: must match admin_username
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


  # (Optional) keep your lifecycle ignores if Azure adds defaults later
  lifecycle {
    ignore_changes = [
      tags["LastModifiedBy"],
      boot_diagnostics,
    ]
  }
}
