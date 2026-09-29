output "resource_group_name" {
  description = "Name of the Resource Group"
  value       = azurerm_resource_group.demo.name
}

output "resource_group_id" {
  description = "ID of the Resource Group"
  value       = azurerm_resource_group.demo.id
}