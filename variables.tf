# identyfikator subskrypcji w azure
variable "subscription_id" {
  type        = string
  description = "Identyfikator subskrypcji Azure"
}

# nazwa grupy zasobow
variable "resource_group_name" {
  type        = string
  description = "Nazwa grupy zasobow"
  default     = "rg-azure-terraform"
}

# region wdrozenia infrastruktury
variable "location" {
  type        = string
  description = "Region wdrozenia zasobow"
  default     = "polandcentral"
}

# glowna pula adresowa sieci
variable "vnet_cidr" {
  type        = string
  description = "Pula adresowa sieci wirtualnej"
  default     = "10.0.0.0/16"
}

# podsiec dla czesci webowej
variable "subnet_web_cidr" {
  type        = string
  description = "Pula adresowa podsieci web"
  default     = "10.0.1.0/24"
}

# podsiec dla bazy danych
variable "subnet_db_cidr" {
  type        = string
  description = "Pula adresowa podsieci db"
  default     = "10.0.2.0/24"
}

# rozmiar maszyn wirtualnych
variable "vm_size" {
  type        = string
  description = "Typ wielkosci maszyny wirtualnej"
  default     = "Standard_B1s"
}

# nazwa uzytkownika na maszynach
variable "admin_username" {
  type        = string
  description = "Login administratora na maszynach"
  default     = "azureuser"
}

# sciezka do klucza ssh
variable "ssh_public_key_path" {
  type        = string
  description = "Sciezka do klucza publicznego"
  default     = "~/.ssh/id_rsa.pub"
}
