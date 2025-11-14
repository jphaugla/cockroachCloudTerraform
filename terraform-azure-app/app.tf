# terraform-azure-app/app.tf
# Application Node VM resources 

resource "azurerm_public_ip" "app_ip" {
  count               = var.app_nodes
  name                = "${var.owner}-${var.resource_name}-public-ip-app-${count.index}"
  location            = var.virtual_network_location
  resource_group_name = local.resource_group_name
  allocation_method   = "Static"
  zones               = [element(local.app_zones, count.index)]
  sku                 = "Standard"
  tags                = local.tags
}

resource "azurerm_network_interface" "app" {
  count               = var.app_nodes
  name                = "${var.owner}-${var.resource_name}-ni-app-${count.index}"
  location            = var.virtual_network_location
  resource_group_name = local.resource_group_name
  tags                = local.tags

  ip_configuration {
    name                          = "network-interface-app-ip-${count.index}"
    subnet_id                     = azurerm_subnet.private[count.index % length(azurerm_subnet.private)].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.app_ip[count.index].id
  }
}

resource "azurerm_user_assigned_identity" "app" {
  name                = "${var.owner}-${var.resource_name}-uai"
  resource_group_name = local.resource_group_name
  location            = var.virtual_network_location
  tags                = local.tags
}

# Look up the Azure-managed public key object by name and resource group
data "azurerm_ssh_public_key" "ssh_key" {
  name                = var.ssh_key_name
  resource_group_name = var.ssh_key_resource_group
}
 
resource "azurerm_linux_virtual_machine" "app" {
  count               = var.include_app == "yes" ? var.app_nodes : 0
  name                = "${var.owner}-${var.resource_name}-vm-app-${count.index}"
  location            = var.virtual_network_location
  resource_group_name = local.resource_group_name
  size                = var.app_vm_size
  zone                = local.app_zones[count.index % 3]
  tags                = local.tags

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.app.id]
  }

  network_interface_ids = [azurerm_network_interface.app[count.index].id]

  admin_username                  = var.login_username
  disable_password_authentication = true
  admin_ssh_key {
    username   = var.login_username
    public_key = data.azurerm_ssh_public_key.ssh_key.public_key
  }

  source_image_reference {
    offer     = "RHEL"
    publisher = "RedHat"
    sku       = "90-gen2"
    version   = "latest"
  }

  os_disk {
    name                 = "${var.owner}-${var.resource_name}-app-osdisk-${count.index}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = var.app_disk_size
  }
}

resource "local_file" "cluster_cert" {
  filename = "${var.playbook_working_directory}/temp/${var.virtual_network_location}/tls_cert"
  content  = var.crdb_cluster_cert
}

resource "azurerm_role_assignment" "app_write" {
  count                = var.include_app == "yes" ? var.app_nodes : 0
  scope                = azurerm_storage_account.app_storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.app.principal_id
}
