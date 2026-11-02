# zapora sieciowa dla podsieci web
resource "azurerm_network_security_group" "nsg_web" {
  name                = "nsg-web"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  # wpuszczenie ruchu www z internetu
  security_rule {
    name                       = "Allow-HTTP-Inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # dostep ssh z internetu
  security_rule {
    name                       = "Allow-SSH-Inbound"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    Projekt    = "Praca-Inzynierska"
    Warstwa    = "Web-Security"
    Srodowisko = "Test"
  }
}

# przypiecie nsg do podsieci web
resource "azurerm_subnet_network_security_group_association" "assoc_web" {
  subnet_id                 = azurerm_subnet.subnet_web.id
  network_security_group_id = azurerm_network_security_group.nsg_web.id
}

# zapora sieciowa dla bazy danych
resource "azurerm_network_security_group" "nsg_db" {
  name                = "nsg-db"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  # ruch mysql tylko z podsieci web
  security_rule {
    name                       = "Allow-MySQL-From-WebSubnet"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3306"
    source_address_prefix      = var.subnet_web_cidr
    destination_address_prefix = "*"
  }

  # dostep ssh tylko z podsieci web
  security_rule {
    name                       = "Allow-SSH-From-WebSubnet"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.subnet_web_cidr
    destination_address_prefix = "*"
  }

  # blokada calego pozostalego ruchu zewnetrznego
  security_rule {
    name                       = "Deny-All-Other-Inbound"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    Projekt    = "Praca-Inzynierska"
    Warstwa    = "DB-Security"
    Srodowisko = "Test"
  }
}

# przypiecie nsg do podsieci bazy
resource "azurerm_subnet_network_security_group_association" "assoc_db" {
  subnet_id                 = azurerm_subnet.subnet_db.id
  network_security_group_id = azurerm_network_security_group.nsg_db.id
}
