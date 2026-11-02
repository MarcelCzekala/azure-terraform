# azure rezerwuje adresy od .0 do .3 (siec, brama, dns, uslugi wewnetrzne) oraz .255, wiec pierwszy wolny ip to .4

# karta sieciowa serwera web
resource "azurerm_network_interface" "nic_web" {
  name                = "nic-web"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfig-web"
    subnet_id                     = azurerm_subnet.subnet_web.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.4"
    public_ip_address_id          = azurerm_public_ip.pip_web.id
  }

  tags = {
    Projekt    = "Praca-Inzynierska"
    Srodowisko = "Test"
  }
}

# maszyna wirtualna serwera web
resource "azurerm_linux_virtual_machine" "vm_web" {
  name                = "vm-web"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = var.vm_size
  admin_username      = var.admin_username

  network_interface_ids = [
    azurerm_network_interface.nic_web.id
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(pathexpand(var.ssh_public_key_path))
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  tags = {
    Projekt    = "Praca-Inzynierska"
    Warstwa    = "Web"
    Srodowisko = "Test"
  }
}

# karta sieciowa serwera bazy
resource "azurerm_network_interface" "nic_db" {
  name                = "nic-db"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfig-db"
    subnet_id                     = azurerm_subnet.subnet_db.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.2.4"
  }

  tags = {
    Projekt    = "Praca-Inzynierska"
    Srodowisko = "Test"
  }
}

# maszyna wirtualna bazy danych
resource "azurerm_linux_virtual_machine" "vm_db" {
  name                = "vm-db"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = var.vm_size
  admin_username      = var.admin_username

  network_interface_ids = [
    azurerm_network_interface.nic_db.id
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(pathexpand(var.ssh_public_key_path))
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  tags = {
    Projekt    = "Praca-Inzynierska"
    Warstwa    = "Database"
    Srodowisko = "Test"
  }
}
