terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}
# 
# resource "azurerm_resource_group" "environment" {
#   for_each = var.environments

#   name     = "rg-nikhil-${each.key}"
#   location = each.value

#   tags = {
#     environment = each.key
#     managed_by  = "terraform"
#   }
# }

resource "azurerm_resource_group" "environment" {
  for_each = var.environments
  name     = "rg-nikhil-${each.key}"
  location = each.value
  tags = {
    environment = each.key
    managed_by  = "terraform"
  }
}
