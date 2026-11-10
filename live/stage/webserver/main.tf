provider "azurerm" {
  features {}
}

module "network" {
  source = "git::https://github.com/Terraformcristianrdgzzz/terraform-module-azurerm-network.git?ref=v0.1.0"

  resource_group_name = var.resource_group_name
  location            = var.location
  vnet_name           = var.vnet_name
  vnet_address_space  = var.vnet_address_space
  subnet_name         = var.subnet_name
  subnet_prefixes     = var.subnet_prefixes
}

module "webserver" {
  source = "git::https://github.com/Terraformcristianrdgzzz/terraform-module-azurerm-linux-webserver.git?ref=v0.1.0"

  resource_group_name       = var.resource_group_name
  location                  = var.location
  vm_name                   = var.vm_name
  admin_username            = var.admin_username
  admin_ssh_public_key      = var.admin_ssh_public_key
  subnet_id                 = module.network.subnet_id
  ssh_source_address_prefix = var.ssh_source_address_prefix
  os_disk_size_gb           = var.os_disk_size_gb
}
