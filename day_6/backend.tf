terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "saremotetfstate"
    container_name       = "tfstate"
    key                  = "day6.tfstate"
  }
}