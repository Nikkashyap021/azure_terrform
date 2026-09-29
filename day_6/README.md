# Day 6 — Terraform Modules

## 📌 Agenda

* What is a Terraform Module?
* Why do we use Modules?
* Root Module
* Child Module
* Module Structure
* Module Inputs
* Module Outputs
* Calling a Module
* Local Modules
* Reusing Modules
* Azure Resource Group Module
* Practical Implementation
* Interview Questions
* Common Mistakes
* Hands-on Challenge
* Day 6 Checklist

---

# 1. About Day 6

In Day 5, we learned about Terraform Remote State and Azure Backend.

In Day 6, we start learning **Terraform Modules**.

A Terraform Module is a collection of Terraform configuration files that can be reused to create infrastructure.

The basic architecture is:

```text
Root Module
     |
     v
Child Module
     |
     v
Azure Resources
```

---

# 2. Purpose of Day 6

The main goals of Day 6 are:

* Understand Terraform Modules
* Understand Root and Child Modules
* Create a reusable module
* Pass variables to a module
* Create module outputs
* Access module outputs
* Reuse the same module
* Understand module structure
* Learn module concepts from an interview perspective

---

# 3. Why Do We Need Modules?

Suppose we need to create multiple Azure Resource Groups.

Without modules, we may repeatedly write similar Terraform configuration.

```text
Development
     |
     +-- Resource Group Configuration

QA
     |
     +-- Resource Group Configuration

Production
     |
     +-- Resource Group Configuration
```

This creates duplicated code.

With modules:

```text
Resource Group Module
        |
        +-- Development
        +-- QA
        +-- Production
```

The same infrastructure logic can be reused with different inputs.

---

# 4. Day 6 Folder Structure

Each learning day is maintained as an independent Terraform configuration.

```text
D:\azure\terraform
│
├── day_1
├── day_2
├── day_3
├── day_4
├── day_5
│
└── day_6
    │
    ├── main.tf
    ├── variables.tf
    ├── terraform.tfvars
    ├── outputs.tf
    │
    └── modules
        │
        └── resource_group
            ├── main.tf
            ├── variables.tf
            └── outputs.tf
```

---

# 5. Root Module

The directory from which we execute Terraform commands is called the **Root Module**.

For Day 6:

```text
day_6/
```

is the root module.

We execute commands from this directory:

```powershell
terraform init
terraform validate
terraform plan
terraform apply
```

---

# 6. Child Module

A Child Module is a module called by another Terraform configuration.

Our child module is:

```text
modules/resource_group
```

Structure:

```text
modules
└── resource_group
    ├── main.tf
    ├── variables.tf
    └── outputs.tf
```

---

# 7. Module Architecture

The complete flow is:

```text
Root Module
     |
     | Input Variables
     v
Child Module
     |
     v
Azure Resource
     |
     | Output
     v
Root Module
```

---

# 8. Create Day 6 Directory

Open PowerShell:

```powershell
cd D:\azure\terraform
```

Create the directory:

```powershell
mkdir day_6
```

Move into it:

```powershell
cd day_6
```

Create the module directories:

```powershell
mkdir modules
mkdir modules\resource_group
```

---

# 9. Module `main.tf`

Create:

```text
day_6/modules/resource_group/main.tf
```

Add:

```hcl
resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location

  tags = var.tags
}
```

The module uses variables instead of hardcoded values.

---

# 10. Module `variables.tf`

Create:

```text
day_6/modules/resource_group/variables.tf
```

Add:

```hcl
variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "tags" {
  description = "Tags for the Resource Group"
  type        = map(string)
  default     = {}
}
```

The module accepts:

```text
resource_group_name
location
tags
```

as inputs.

---

# 11. Module `outputs.tf`

Create:

```text
day_6/modules/resource_group/outputs.tf
```

Add:

```hcl
output "name" {
  description = "Name of the Resource Group"
  value       = azurerm_resource_group.this.name
}

output "id" {
  description = "ID of the Resource Group"
  value       = azurerm_resource_group.this.id
}

output "location" {
  description = "Location of the Resource Group"
  value       = azurerm_resource_group.this.location
}
```

The module exposes:

```text
name
id
location
```

as outputs.

---

# 12. Root `main.tf`

Create:

```text
day_6/main.tf
```

Add:

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

module "resource_group" {
  source = "./modules/resource_group"

  resource_group_name = var.resource_group_name
  location             = var.location
  tags                 = var.tags
}
```

The important part is:

```hcl
module "resource_group" {
  source = "./modules/resource_group"
}
```

This tells Terraform to use the local module.

---

# 13. Root `variables.tf`

Create:

```text
day_6/variables.tf
```

Add:

```hcl
variable "resource_group_name" {
  description = "Name of the Resource Group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "tags" {
  description = "Common Resource Group tags"
  type        = map(string)
}
```

---

# 14. `terraform.tfvars`

Create:

```text
day_6/terraform.tfvars
```

Add:

```hcl
resource_group_name = "rg-nikhil-day6"
location             = "Central India"

tags = {
  environment = "dev"
  managed_by  = "terraform"
  project     = "terraform-learning"
  day         = "day6"
}
```

---

# 15. Root `outputs.tf`

Create:

```text
day_6/outputs.tf
```

Add:

```hcl
output "resource_group_name" {
  description = "Resource Group name returned by the module"
  value       = module.resource_group.name
}

output "resource_group_id" {
  description = "Resource Group ID returned by the module"
  value       = module.resource_group.id
}

output "resource_group_location" {
  description = "Resource Group location returned by the module"
  value       = module.resource_group.location
}
```

The module output is accessed using:

```text
module.<module_name>.<output_name>
```

Example:

```hcl
module.resource_group.name
```

---

# 16. Module Inputs

Inputs are values passed from the root module to the child module.

```text
Root Module
     |
     | resource_group_name
     | location
     | tags
     v
Child Module
```

Example:

```hcl
module "resource_group" {
  source = "./modules/resource_group"

  resource_group_name = var.resource_group_name
  location             = var.location
  tags                 = var.tags
}
```

---

# 17. Module Outputs

Outputs are values returned by the child module.

```text
Child Module
     |
     | name
     | id
     | location
     v
Root Module
```

Example:

```hcl
output "resource_group_name" {
  value = module.resource_group.name
}
```

---

# 18. Input vs Output

### Input

```text
Root Module → Child Module
```

Used to provide information to the module.

### Output

```text
Child Module → Root Module
```

Used to expose information from the module.

Remember:

```text
Input  → Module
Output ← Module
```

---

# 19. Initialize Terraform

From:

```text
D:\azure\terraform\day_6
```

run:

```powershell
terraform init
```

Terraform will initialize:

* AzureRM provider
* Local module
* Terraform working directory

Expected output:

```text
Initializing modules...
Initializing provider plugins...
Terraform has been successfully initialized!
```

---

# 20. Format Terraform Files

Run:

```powershell
terraform fmt -recursive
```

The `-recursive` option also formats files inside the module directory.

---

# 21. Validate Configuration

Run:

```powershell
terraform validate
```

Expected:

```text
Success! The configuration is valid.
```

---

# 22. Create Execution Plan

Run:

```powershell
terraform plan
```

The resource address should look similar to:

```text
module.resource_group.azurerm_resource_group.this
```

This is different from a resource directly defined in the root module.

---

# 23. Apply Configuration

Run:

```powershell
terraform apply
```

Enter:

```text
yes
```

Terraform will create:

```text
rg-nikhil-day6
```

---

# 24. Check Terraform State

Run:

```powershell
terraform state list
```

Expected:

```text
module.resource_group.azurerm_resource_group.this
```

The resource is now associated with the module.

---

# 25. Reusing a Module

The same module can be called multiple times.

Example:

```hcl
module "dev_resource_group" {
  source = "./modules/resource_group"

  resource_group_name = "rg-nikhil-dev"
  location             = "Central India"

  tags = {
    environment = "dev"
  }
}
```

Another instance:

```hcl
module "qa_resource_group" {
  source = "./modules/resource_group"

  resource_group_name = "rg-nikhil-qa"
  location             = "Central India"

  tags = {
    environment = "qa"
  }
}
```

Both use:

```text
./modules/resource_group
```

---

# 26. Module Sources

Terraform supports different module sources.

### Local Module

```hcl
source = "./modules/resource_group"
```

### Git Module

```hcl
source = "git::https://example.com/terraform-modules.git"
```

### Terraform Registry

Modules can also be consumed from the Terraform Registry.

For Day 6, we are focusing on **local modules**.

---

# 27. Root Module vs Child Module

| Root Module                               | Child Module                    |
| ----------------------------------------- | ------------------------------- |
| Main Terraform configuration              | Reusable configuration          |
| Terraform commands run here               | Called by another module        |
| Calls child modules                       | Creates reusable infrastructure |
| Usually manages environment configuration | Accepts variables               |
| Defines provider configuration            | Uses provider passed from root  |

---

# 28. Why Modules Are Important in Real Projects

Without modules:

```text
Project
│
├── Dev
│   └── Repeated Terraform Code
│
├── QA
│   └── Repeated Terraform Code
│
└── Production
    └── Repeated Terraform Code
```

With modules:

```text
Project
│
├── modules
│   └── resource_group
│
├── dev
├── qa
└── production
```

The infrastructure logic can be standardized and reused.

---

# 29. Important Module Syntax

### Calling a module

```hcl
module "resource_group" {
  source = "./modules/resource_group"
}
```

### Passing an input

```hcl
resource_group_name = var.resource_group_name
```

### Accessing an output

```hcl
module.resource_group.name
```

The general output syntax is:

```text
module.<module_name>.<output_name>
```

---

# 30. Common Mistakes

## Mistake 1 — Incorrect Local Module Path

Incorrect:

```hcl
source = "modules/resource_group"
```

Correct:

```hcl
source = "./modules/resource_group"
```

---

## Mistake 2 — Missing Module Output

If the module defines:

```hcl
output "name" {
  value = azurerm_resource_group.this.name
}
```

then use:

```hcl
module.resource_group.name
```

Do not use an output that the module has not defined.

---

## Mistake 3 — Forgetting `terraform init`

After adding a new module, run:

```powershell
terraform init
```

---

## Mistake 4 — Hardcoding Everything

Avoid unnecessarily hardcoding values inside reusable modules.

Prefer:

```hcl
resource_group_name = var.resource_group_name
```

instead of:

```hcl
name = "rg-production"
```

---

# 31. Interview Questions

## Q1. What is a Terraform Module?

A Terraform Module is a collection of Terraform configuration files used to organize and reuse infrastructure code.

---

## Q2. Why do we use Modules?

Modules provide:

* Reusability
* Maintainability
* Standardization
* Better organization
* Reduced code duplication

---

## Q3. What is a Root Module?

The Root Module is the Terraform configuration from which Terraform commands are executed.

---

## Q4. What is a Child Module?

A Child Module is a Terraform module called by another module.

---

## Q5. How do you call a local module?

```hcl
module "resource_group" {
  source = "./modules/resource_group"
}
```

---

## Q6. How do you pass values to a module?

Using module arguments:

```hcl
module "resource_group" {
  source = "./modules/resource_group"

  resource_group_name = var.resource_group_name
  location             = var.location
}
```

---

## Q7. How do you access a module output?

```hcl
module.resource_group.name
```

---

## Q8. Can a module be reused multiple times?

Yes.

The same module can be called multiple times with different inputs.

---

## Q9. What is the difference between a variable and an output?

A variable is an input to a module.

An output exposes a value from a module.

```text
Variable → Module
Output   ← Module
```

---

## Q10. Where should provider configuration normally be placed?

For a basic module design, provider configuration is normally managed by the root module, while child modules focus on resources and inputs/outputs.

---

# 32. Interview Scenario

### Question

Your company has 20 Azure Resource Groups with the same naming and tagging standards. Developers are copying the same Terraform code for every Resource Group.

How would you improve the design?

### Expected Approach

Create a reusable Resource Group module:

```text
modules/
└── resource_group/
    ├── main.tf
    ├── variables.tf
    └── outputs.tf
```

Then call the module with different values for each environment.

```text
Resource Group Module
        |
        +── Development
        +── QA
        +── Production
```

This reduces duplicated Terraform code and provides a consistent infrastructure pattern.

---

# 33. Hands-On Challenge

Create a second Resource Group using the same module.

Add:

```hcl
module "qa_resource_group" {
  source = "./modules/resource_group"

  resource_group_name = "rg-nikhil-day6-qa"
  location             = "Central India"

  tags = {
    environment = "qa"
    managed_by  = "terraform"
    day         = "day6"
  }
}
```

Then run:

```powershell
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

Check the resources:

```powershell
terraform state list
```

---

# 34. Day 6 Commands

```powershell
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
terraform state list
terraform state show module.resource_group.azurerm_resource_group.this
```

To destroy the Day 6 infrastructure:

```powershell
terraform destroy
```

---

# 35. Day 6 Checklist

* [ ] Understand Terraform Modules
* [ ] Understand Root Module
* [ ] Understand Child Module
* [ ] Create a module directory
* [ ] Create module `main.tf`
* [ ] Create module `variables.tf`
* [ ] Create module `outputs.tf`
* [ ] Call a local module
* [ ] Pass variables to a module
* [ ] Read module outputs
* [ ] Reuse the same module
* [ ] Understand module resource addresses
* [ ] Run `terraform init`
* [ ] Run `terraform fmt -recursive`
* [ ] Run `terraform validate`
* [ ] Run `terraform plan`
* [ ] Run `terraform apply`
* [ ] Practice interview questions

---

# 36. Key Takeaways

The most important architecture to remember:

```text
Root Module
      |
      | Inputs
      v
Child Module
      |
      v
Azure Resources
      |
      | Outputs
      v
Root Module
```

Important syntax:

```hcl
module "resource_group" {
  source = "./modules/resource_group"

  resource_group_name = var.resource_group_name
  location             = var.location
  tags                 = var.tags
}
```

Accessing an output:

```hcl
module.resource_group.name
```

General pattern:

```text
module.<module_name>.<output_name>
```

---

# 37. Next Day

## Day 7 — Advanced Modules & Environment-Based Infrastructure

Topics:

* Multiple module instances
* Environment-specific configuration
* Module composition
* Module dependencies
* Module outputs between resources
* Better module structure
* Practical Azure infrastructure
* Real-world Terraform project structure
* Interview scenarios
