# glowna grupa zasobow projektu
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# wirtualna siec dla maszyn
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-main"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = [var.vnet_cidr]
  tags                = var.tags
}

# publiczna podsiec serwera web
resource "azurerm_subnet" "subnet_web" {
  name                 = "subnet-web"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_web_cidr]
}

# prywatna podsiec bazy danych
resource "azurerm_subnet" "subnet_db" {
  name                 = "subnet-db"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_db_cidr]
}

# publiczny adres ip dla vm-web
resource "azurerm_public_ip" "pip_web" {
  name                = "pip-web"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}
