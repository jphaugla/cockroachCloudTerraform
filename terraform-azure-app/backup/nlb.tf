#########################################
# Terraform: Azure Load Balancer for App Nodes
#########################################


# Public IP for Load Balancer (only if include_load_balancer == "yes")
resource "azurerm_public_ip" "load_balancer_ip" {
  count               = var.include_load_balancer == "yes" ? 1 : 0
  name                = "${var.owner}-${var.resource_name}-public-ip-load-balancer"
  location            = var.virtual_network_location
  resource_group_name = local.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.tags
}

# Private Load Balancer
resource "azurerm_lb" "private_load_balancer" {
  count               = var.include_load_balancer == "yes" ? 1 : 0
  name                = "${var.owner}-${var.resource_name}-private-load-balancer"
  location            = var.virtual_network_location
  resource_group_name = local.resource_group_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "private_frontend"
    subnet_id                     = azurerm_subnet.private[count.index].id
    private_ip_address_allocation = "Dynamic"
  }

  depends_on = [azurerm_subnet.private]
}

# Public Load Balancer
resource "azurerm_lb" "public_load_balancer" {
  count               = var.include_load_balancer == "yes" ? 1 : 0
  name                = "${var.owner}-${var.resource_name}-public-load-balancer"
  location            = var.virtual_network_location
  resource_group_name = local.resource_group_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "public_frontend"
    public_ip_address_id = azurerm_public_ip.load_balancer_ip[0].id
  }
}

# Backend Pools renamed for App
resource "azurerm_lb_backend_address_pool" "app_private_pool" {
  count           = var.include_load_balancer == "yes" ? 1 : 0
  name            = "${var.owner}-${var.resource_name}-app-private-backend-pool"
  loadbalancer_id = azurerm_lb.private_load_balancer[0].id
}

resource "azurerm_lb_backend_address_pool" "app_public_pool" {
  count           = var.include_load_balancer == "yes" ? 1 : 0
  name            = "${var.owner}-${var.resource_name}-app-public-backend-pool"
  loadbalancer_id = azurerm_lb.public_load_balancer[0].id
}

# Probes — only for your application’s HTTP health endpoint
resource "azurerm_lb_probe" "private_app_probe" {
  count               = var.include_load_balancer == "yes" ? 1 : 0
  name                = "${var.owner}-${var.resource_name}-private-app-probe"
  loadbalancer_id     = azurerm_lb.private_load_balancer[0].id
  protocol            = "Http"
  port                = 8080
  request_path        = "/health?ready=1"
  interval_in_seconds = 5
}

resource "azurerm_lb_probe" "public_app_probe" {
  count               = var.include_load_balancer == "yes" ? 1 : 0
  name                = "${var.owner}-${var.resource_name}-public-app-probe"
  loadbalancer_id     = azurerm_lb.public_load_balancer[0].id
  protocol            = "Http"
  port                = 8080
  request_path        = "/health?ready=1"
  interval_in_seconds = 5
}

# Public-facing rules for App and CockroachDB ports
resource "azurerm_lb_rule" "public_admin_rule" {
  count                          = var.include_load_balancer == "yes" ? 1 : 0
  loadbalancer_id                = azurerm_lb.public_load_balancer[0].id
  name                           = "${var.owner}-${var.resource_name}-pub-admin-rule"
  protocol                       = "Tcp"
  frontend_port                  = 8080
  backend_port                   = 8080
  frontend_ip_configuration_name = "public_frontend"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.app_public_pool[0].id]
  probe_id                       = azurerm_lb_probe.public_app_probe[0].id
}

resource "azurerm_lb_rule" "public_crdb_rule" {
  count                          = var.include_load_balancer == "yes" ? 1 : 0
  loadbalancer_id                = azurerm_lb.public_load_balancer[0].id
  name                           = "${var.owner}-${var.resource_name}-pub-crdb-rule"
  protocol                       = "Tcp"
  frontend_port                  = 26257
  backend_port                   = 26257
  frontend_ip_configuration_name = "public_frontend"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.app_public_pool[0].id]
  probe_id                       = azurerm_lb_probe.public_app_probe[0].id
}

# Private LB rule opening all internal traffic for CockroachDB port

resource "azurerm_lb_rule" "private_crdb" {
  count                          = var.include_load_balancer == "yes" ? 1 : 0
  loadbalancer_id                = azurerm_lb.private_load_balancer[0].id
  name                           = "${var.owner}-${var.resource_name}-priv-crdb"
  protocol                       = "Tcp"
  frontend_ip_configuration_name = "private_frontend"
  frontend_port                  = 26257
  backend_port                   = 26257
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.app_private_pool[0].id]
}

resource "azurerm_lb_rule" "private_sql" {
  count                          = var.include_load_balancer == "yes" ? 1 : 0
  loadbalancer_id                = azurerm_lb.private_load_balancer[0].id
  name                           = "${var.owner}-${var.resource_name}-priv-sql"
  protocol                       = "Tcp"
  frontend_ip_configuration_name = "private_frontend"
  frontend_port                  = 26258
  backend_port                   = 26258
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.app_private_pool[0].id]
}

resource "azurerm_lb_rule" "private_8080_http" {
  count                          = var.include_load_balancer == "yes" ? 1 : 0
  loadbalancer_id                = azurerm_lb.private_load_balancer[0].id
  name                           = "${var.owner}-${var.resource_name}-priv-http-8080"
  protocol                       = "Tcp"
  frontend_ip_configuration_name = "private_frontend"
  frontend_port                  = 8080
  backend_port                   = 8080
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.app_private_pool[0].id]
}
resource "azurerm_lb_rule" "private_8000_http" {
  count                          = var.include_load_balancer == "yes" ? 1 : 0
  loadbalancer_id                = azurerm_lb.private_load_balancer[0].id
  name                           = "${var.owner}-${var.resource_name}-priv-http-8000"
  protocol                       = "Tcp"
  frontend_ip_configuration_name = "private_frontend"
  frontend_port                  = 8000
  backend_port                   = 8000
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.app_private_pool[0].id]
}
resource "azurerm_lb_rule" "private_80_http" {
  count                          = var.include_load_balancer == "yes" ? 1 : 0
  loadbalancer_id                = azurerm_lb.private_load_balancer[0].id
  name                           = "${var.owner}-${var.resource_name}-priv-http-80"
  protocol                       = "Tcp"
  frontend_ip_configuration_name = "private_frontend"
  frontend_port                  = 80
  backend_port                   = 80
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.app_private_pool[0].id]
}
#########################################
# Associate App VM NICs with the Private LB
#########################################
resource "azurerm_network_interface_backend_address_pool_association" "app_private_pool_association" {
  count = var.include_load_balancer == "yes" ? var.app_nodes : 0

  network_interface_id    = azurerm_network_interface.app[count.index].id
  ip_configuration_name   = "network-interface-app-ip-${count.index}"
  backend_address_pool_id = azurerm_lb_backend_address_pool.app_private_pool[0].id

  depends_on = [
    azurerm_network_interface.app,
    azurerm_lb_backend_address_pool.app_private_pool,
  ]
}

#########################################
# Private Link Service for LocalStack S3
#########################################
resource "azurerm_private_link_service" "s3_proxy_pls" {
  name                = "${var.owner}-${var.resource_name}-pls-s3"
  location            = var.virtual_network_location
  resource_group_name = local.resource_group_name

  # reference your ILB frontend
  load_balancer_frontend_ip_configuration_ids = [
    azurerm_lb.private_load_balancer[0]
      .frontend_ip_configuration[0]
      .id
  ]

  # Required NAT block
  nat_ip_configuration {
    name      = "pls-nat"
    subnet_id = azurerm_subnet.private[0].id
    primary   = true
  }

  enable_proxy_protocol = false
  tags                  = local.tags
}
