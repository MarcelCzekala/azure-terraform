# nazwa grupy zasobow
output "resource_group_name" {
  description = "Nazwa grupy zasobow"
  value       = azurerm_resource_group.rg.name
}

# publiczne ip serwera web
output "web_public_ip" {
  description = "Publiczne IP serwera webowego"
  value       = azurerm_public_ip.pip_web.ip_address
}

# prywatne ip serwera web
output "web_private_ip" {
  description = "Prywatne IP serwera webowego"
  value       = azurerm_network_interface.nic_web.private_ip_address
}

# prywatne ip bazy danych
output "db_private_ip" {
  description = "Prywatne IP bazy danych"
  value       = azurerm_network_interface.nic_db.private_ip_address
}

# polecenie ssh do vm-web
output "ssh_command_web" {
  description = "Logowanie na serwer webowy"
  value       = "ssh ${var.admin_username}@${azurerm_public_ip.pip_web.ip_address}"
}

# polecenie ssh przez jump host
output "ssh_command_db_via_jump" {
  description = "Logowanie na baze przez jump host"
  value       = "ssh -J ${var.admin_username}@${azurerm_public_ip.pip_web.ip_address} ${var.admin_username}@${azurerm_network_interface.nic_db.private_ip_address}"
}

# polecenie ssh z web do db
output "ssh_command_internal_web_to_db" {
  description = "Polaczenie z vm-web do vm-db"
  value       = "ssh ${var.admin_username}@${azurerm_network_interface.nic_db.private_ip_address}"
}
