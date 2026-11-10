output "website_url" {
  description = "HTTP URL for the Apache welcome page."
  value       = module.webserver.website_url
}

output "public_ip_address" {
  description = "Public IPv4 address assigned to the web server."
  value       = module.webserver.public_ip_address
}

output "vm_name" {
  description = "Name of the stage Linux virtual machine."
  value       = module.webserver.vm_name
}
