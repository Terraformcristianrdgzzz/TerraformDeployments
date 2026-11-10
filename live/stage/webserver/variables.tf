variable "resource_group_name" {
  description = "Existing resource group where stage resources will be created."
  type        = string
}

variable "location" {
  description = "Azure region for stage resources."
  type        = string
}

variable "vnet_name" {
  description = "Name of the stage virtual network."
  type        = string
}

variable "vnet_address_space" {
  description = "IPv4 CIDR address space for the stage virtual network."
  type        = list(string)
}

variable "subnet_name" {
  description = "Name of the web server subnet."
  type        = string
}

variable "subnet_prefixes" {
  description = "IPv4 CIDR prefixes for the web server subnet."
  type        = list(string)
}

variable "vm_name" {
  description = "Name of the stage web server VM."
  type        = string
}

variable "admin_username" {
  description = "Linux administrator username for the VM."
  type        = string
}

variable "admin_ssh_public_key" {
  description = "SSH public key supplied through the GitHub stage environment variable ADMIN_SSH_PUBLIC_KEY."
  type        = string
}

variable "ssh_source_address_prefix" {
  description = "Optional trusted IPv4 CIDR allowed to SSH. Null disables SSH ingress."
  type        = string
  default     = null
}

variable "os_disk_size_gb" {
  description = "Linux OS disk size in GB."
  type        = number
  default     = 30
}
