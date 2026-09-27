Sure, Nikhil. Here is the **complete `README.md` content** ready to copy and paste into `day_2/README.md`.

# Terraform Day 2 — Variables, Outputs, Locals & Tags

## 📋 Agenda

* Terraform project structure
* AzureRM provider configuration
* Terraform variables
* `terraform.tfvars`
* Terraform outputs
* Terraform locals
* Azure resource tags
* Terraform workflow
* Terraform commands
* Interview-focused questions and answers

---

## 🎯 About Day 2

Day 2 focuses on making Terraform configurations **dynamic, reusable, and maintainable**.

In Day 1, we created an Azure Resource Group using hard-coded values.

In Day 2, we improve the configuration by using:

* Variables
* `terraform.tfvars`
* Outputs
* Locals
* Azure tags

This approach makes the Terraform code easier to reuse across different environments such as:

* Development
* Staging
* Production

---

## 🎯 Purpose of Day 2

The main purpose of Day 2 is to understand how Terraform handles **input values, reusable configuration, and output values**.

Instead of hard-coding:

```hcl
name     = "rg-nikhil-day2"
location = "Central India"
```

we use variables:

```hcl
name     = var.resource_group_name
location = var.location
```

This makes our Terraform configuration more flexible.

---

# 📁 Project Structure

```text
day_2/
│
├── main.tf
├── variables.tf
├── terraform.tfvars
├── outputs.tf
├── locals.tf
├── README.md
└── .terraform.lock.hcl
```

The following files/directories are generated locally and should not normally be committed:

```text
.terraform/
terraform.tfstate
terraform.tfstate.backup
```

---

# ⚙️ Configuration

## 1. AzureRM Provider

The AzureRM provider is configured in `main.tf`.

```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.0"
    }
  }
}

provider "azurerm" {
  features {}
}
```

### Explanation

`required_providers` tells Terraform which provider the configuration requires.

```text
hashicorp/azurerm
```

is the Terraform provider used to manage Azure resources.

The following block configures the Azure provider:

```hcl
provider "azurerm" {
  features {}
}
```

---

# 2. Terraform Variables

Variables are defined in `variables.tf`.

```hcl
variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}
```

Variables allow us to avoid hard-coding values inside resources.

---

# 3. terraform.tfvars

The actual variable values are stored in `terraform.tfvars`.

```hcl
resource_group_name = "rg-nikhil-day2"
location             = "Central India"
environment          = "dev"
project_name         = "terraform-learning"
```

Terraform automatically loads values from `terraform.tfvars`.

> **Note:** `terraform.tfvars` may contain sensitive information in real projects, so it should generally not be committed to Git.

---

# 4. Terraform Locals

Locals are defined in `locals.tf`.

```hcl
locals {
  common_tags = {
    environment = var.environment
    owner       = "nikhil"
    managed_by  = "terraform"
    project     = var.project_name
  }
}
```

Locals are useful when the same value or expression needs to be reused multiple times.

---

# 5. Azure Resource Group

The Resource Group is created in `main.tf`.

```hcl
resource "azurerm_resource_group" "demo" {
  name     = var.resource_group_name
  location = var.location

  tags = local.common_tags
}
```

Here:

```text
var.resource_group_name
```

gets the Resource Group name from the variable.

```text
var.location
```

gets the Azure region.

```text
local.common_tags
```

provides the common tags.

---

# 6. Terraform Outputs

Outputs are defined in `outputs.tf`.

```hcl
output "resource_group_name" {
  description = "The name of the Resource Group"
  value       = azurerm_resource_group.demo.name
}

output "resource_group_location" {
  description = "The location of the Resource Group"
  value       = azurerm_resource_group.demo.location
}
```

Outputs allow us to display useful information after Terraform creates the infrastructure.

---

# 🔄 Terraform Workflow

The basic Terraform workflow used in Day 2 is:

```text
Write Terraform Code
        ↓
terraform fmt
        ↓
terraform init
        ↓
terraform validate
        ↓
terraform plan
        ↓
terraform apply
        ↓
Azure Infrastructure
```

---

# 🛠️ Terraform Commands

## Terraform Init

```powershell
terraform init
```

Initializes the Terraform working directory and downloads required providers and modules.

---

## Terraform Format

```powershell
terraform fmt
```

Formats Terraform configuration files according to Terraform's standard formatting.

---

## Terraform Validate

```powershell
terraform validate
```

Checks whether the Terraform configuration is syntactically valid and internally consistent.

---

## Terraform Plan

```powershell
terraform plan
```

Creates an execution plan showing what Terraform intends to create, modify, or destroy.

`terraform plan` does **not** apply the changes.

---

## Terraform Apply

```powershell
terraform apply
```

Applies the Terraform configuration and creates or modifies Azure infrastructure.

---

## Terraform Output

```powershell
terraform output
```

Displays the outputs defined in `outputs.tf`.

---

## Terraform Destroy

```powershell
terraform destroy
```

Deletes infrastructure managed by Terraform.

Use this carefully, especially in production environments.

---

# 🧠 Important Terraform Concepts

## Variable

A variable is an input value used to make Terraform configuration dynamic.

Example:

```hcl
variable "location" {
  type = string
}
```

Usage:

```hcl
location = var.location
```

---

## terraform.tfvars

`terraform.tfvars` contains values for Terraform variables.

Example:

```hcl
location = "Central India"
```

---

## Local

A local value is an internally reusable value or expression.

Example:

```hcl
locals {
  environment = "dev"
}
```

Usage:

```hcl
local.environment
```

---

## Output

An output exposes useful information from Terraform.

Example:

```hcl
output "resource_group_name" {
  value = azurerm_resource_group.demo.name
}
```

---

# 📊 Variable vs Local vs Output

| Feature            | Purpose                             |
| ------------------ | ----------------------------------- |
| Variable           | Input to Terraform                  |
| Local              | Reusable value inside configuration |
| Output             | Exposes information from Terraform  |
| `terraform.tfvars` | Provides values to variables        |

Simple way to remember:

```text
Variable → Input
Local    → Reusable internal value
Resource → Infrastructure
Output   → Result
```

---

# 🏷️ Azure Resource Tags

Tags are key-value pairs used to organize Azure resources.

Example:

```hcl
tags = {
  environment = "dev"
  owner       = "nikhil"
  managed_by  = "terraform"
}
```

Tags can be useful for:

* Resource organization
* Ownership
* Cost management
* Environment identification
* Automation
* Governance

---

# 🔐 Git Best Practices

The following files/directories should generally not be committed:

```text
.terraform/
terraform.tfstate
terraform.tfstate.backup
*.tfvars
```

The Terraform lock file should normally be committed:

```text
.terraform.lock.hcl
```

Example `.gitignore`:

```gitignore
# Terraform working directory
**/.terraform/

# Terraform state
*.tfstate
*.tfstate.*

# Variable files
*.tfvars
*.tfvars.json

# Crash logs
crash.log
crash.*.log

# Override files
override.tf
override.tf.json
*_override.tf
*_override.tf.json
```

---

# 🎤 Interview Questions & Answers

## Q1. What is a Terraform variable?

A Terraform variable is an input parameter that allows us to make Terraform configurations dynamic and reusable instead of hard-coding values.

Example:

```hcl
variable "location" {
  type = string
}
```

---

## Q2. What is the difference between a variable and a local?

A variable is used to provide input to a Terraform module, while a local is used to define reusable values or expressions inside the Terraform configuration.

```text
Variable → External/Input value
Local    → Internal/Reused value
```

---

## Q3. What is `terraform.tfvars`?

`terraform.tfvars` is a variable values file used to provide values for declared Terraform input variables.

Example:

```hcl
environment = "dev"
location    = "Central India"
```

---

## Q4. What is the difference between `var` and `local`?

Variables are accessed using:

```hcl
var.variable_name
```

Locals are accessed using:

```hcl
local.local_name
```

Example:

```hcl
var.location
```

and:

```hcl
local.common_tags
```

---

## Q5. What is the purpose of Terraform outputs?

Outputs expose useful information from Terraform resources or modules.

For example:

```hcl
output "resource_group_name" {
  value = azurerm_resource_group.demo.name
}
```

---

## Q6. What is `terraform plan`?

`terraform plan` creates an execution plan that shows what Terraform intends to change without actually applying those changes.

---

## Q7. What is `terraform apply`?

`terraform apply` executes the Terraform configuration and creates, updates, or deletes infrastructure according to the configuration.

---

## Q8. What does `terraform init` do?

`terraform init` initializes a Terraform working directory and downloads the required providers and modules.

---

## Q9. What is `.terraform.lock.hcl`?

`.terraform.lock.hcl` records the selected provider versions and dependency information.

It helps ensure consistent provider versions across different environments.

It should normally be committed to Git.

---

## Q10. Why should `.terraform/` not be committed?

The `.terraform/` directory contains downloaded providers and local Terraform working data.

It can be recreated using:

```powershell
terraform init
```

Therefore, it normally should not be committed.

---

## Q11. Why should `terraform.tfstate` not be committed to Git?

Terraform state contains information about managed infrastructure and can potentially contain sensitive information.

For team environments, state should generally be stored in a secure remote backend rather than committed to Git.

---

## Q12. What are Azure tags?

Azure tags are key-value pairs attached to Azure resources.

Example:

```hcl
tags = {
  environment = "dev"
  owner       = "nikhil"
}
```

They can be used for resource organization, ownership, cost management, and automation.

---

# 🔥 Scenario-Based Interview Questions

## Q13. You have 20 Azure resources and all resources require the same tags. How would you avoid duplicating the tags?

I would use Terraform `locals` to define common tags once.

Example:

```hcl
locals {
  common_tags = {
    environment = var.environment
    owner       = "nikhil"
    managed_by  = "terraform"
  }
}
```

Then reuse them:

```hcl
tags = local.common_tags
```

This reduces duplication and makes the Terraform configuration easier to maintain.

---

## Q14. You have Dev, QA, and Production environments. Would you hard-code the Azure region in every resource?

No.

I would use a variable:

```hcl
variable "location" {
  type = string
}
```

Then provide the environment-specific value through a variable file or another appropriate configuration mechanism.

Example:

```hcl
location = "Central India"
```

This makes the configuration reusable across environments.

---

## Q15. What happens if you run `terraform plan`?

Terraform compares the desired infrastructure defined in the configuration with the current state and available infrastructure information.

It then generates a plan showing proposed additions, changes, and deletions.

No infrastructure changes are applied by `terraform plan`.

---

# 🎯 Day 2 Learning Summary

By completing Day 2, we learned:

* How to configure the AzureRM provider
* How Terraform variables work
* How to use `terraform.tfvars`
* How to use Terraform outputs
* How to use locals
* How to create common Azure tags
* How to structure Terraform configuration
* Basic Terraform workflow
* Terraform Git best practices
* Common Terraform interview questions

---

# 🚀 Next — Day 3

Day 3 will cover:

```text
Terraform Expressions
        ↓
Terraform Functions
        ↓
Conditional Expressions
        ↓
count
        ↓
for_each
        ↓
for expressions
        ↓
Dynamic Azure Resources
```

The main objective will be to move from **static Terraform configuration to dynamic infrastructure**.
