# storage.tf
resource "azurerm_storage_account" "app_storage" {
  name                     = "${var.owner}${var.resource_name}sa2"
  resource_group_name      = local.resource_group_name
  location                 = var.virtual_network_location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  https_traffic_only_enabled = true

  tags = local.tags
}

resource "azurerm_storage_container" "app_container" {
  name                 = "app-uploads"
  storage_account_id   = azurerm_storage_account.app_storage.id
  container_access_type = "private"
}

data "azurerm_storage_account_sas" "full_access" {
  connection_string = azurerm_storage_account.app_storage.primary_connection_string

  https_only = true
  start      = timestamp()
  expiry     = timeadd(timestamp(), "24h")

  resource_types {
    service   = false
    container = true
    object    = true
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  permissions {
    read    = true   # r
    list    = true   # l
    write   = true   # w
    delete  = true   # d
    add     = true   # a
    create  = true   # c
    update  = false  # u
    process = false  # p
    filter  = false  # f
    tag     = false  # t
  }
}
