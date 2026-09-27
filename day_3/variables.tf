variable "name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region name"
  type        = string
}

variable "environments" {
  description = "Environment names and Azure regions"

  type = map(string)
}
