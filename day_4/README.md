# Terraform Day 4 — Terraform State Management

## 📋 Agenda

* What is Terraform State?
* `terraform.tfstate`
* Desired State vs Actual Infrastructure
* Terraform State and Resource Mapping
* Terraform Resource Address
* `terraform state list`
* `terraform state show`
* `terraform state pull`
* State Drift
* Terraform Import
* `terraform state rm`
* Local State vs Remote State
* Git and Terraform State
* Interview-focused questions and answers

---

# 🎯 About Day 4

Day 4 focuses on **Terraform State Management**.

Terraform State is one of the most important concepts in Terraform because Terraform needs to keep track of the infrastructure it manages.

The default local state file is:

```text
terraform.tfstate
```

Terraform uses state to maintain a relationship between:

```text
Terraform Configuration
        ↓
Terraform State
        ↓
Azure Infrastructure
```

---

# 🎯 Purpose of Day 4

The purpose of Day 4 is to understand:

* What Terraform State is
* Why Terraform needs State
* How Terraform tracks Azure resources
* How to inspect Terraform State
* How Terraform handles infrastructure changes
* What State Drift means
* How existing Azure resources can be imported
* Why State should not be committed to Git
* Introduction to Remote State

---

# 📁 Project Structure

```text
day_4/
│
├── main.tf
├── variables.tf
├── terraform.tfvars
├── outputs.tf
├── README.md
└── .terraform.lock.hcl
```

Terraform also generates:

```text
.terraform/
terraform.tfstate
terraform.tfstate.backup
```

These files are generated locally.

---

# ⚙️ Terraform Configuration

## 1. AzureRM Provider

`main.tf`:

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

The AzureRM provider allows Terraform to manage Azure resources.

---

# 2. Azure Resource Group

```hcl
resource "azurerm_resource_group" "demo" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    environment = var.environment
    managed_by  = "terraform"
    owner       = "nikhil"
  }
}
```

The Terraform resource address is:

```text
azurerm_resource_group.demo
```

---

# 3. Variables

`variables.tf`:

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
```

---

# 4. terraform.tfvars

```hcl
resource_group_name = "rg-nikhil-day4"
location             = "Central India"
environment          = "dev"
```

---

# 5. Outputs

`outputs.tf`:

```hcl
output "resource_group_name" {
  value = azurerm_resource_group.demo.name
}

output "resource_group_id" {
  value = azurerm_resource_group.demo.id
}
```

---

# 🔄 Terraform Workflow

The Day 4 workflow is:

```text
Write Configuration
        ↓
terraform init
        ↓
terraform fmt
        ↓
terraform validate
        ↓
terraform plan
        ↓
terraform apply
        ↓
Terraform State
        ↓
Azure Infrastructure
```

---

# 🧠 What is Terraform State?

Terraform State is a record that Terraform uses to track infrastructure it manages.

The default local state file is:

```text
terraform.tfstate
```

For example, Terraform creates:

```text
Azure Resource Group
        ↓
rg-nikhil-day4
```

Terraform stores information about this resource in its state.

Conceptually:

```text
Terraform Configuration
        ↓
Desired State
        ↓
Terraform State
        ↓
Azure Infrastructure
```

---

# 🎯 Desired State vs Actual Infrastructure

Terraform configuration represents the desired infrastructure.

For example:

```hcl
resource "azurerm_resource_group" "demo" {
  name     = "rg-nikhil-day4"
  location = "Central India"
}
```

This describes what we want.

Azure contains the actual infrastructure.

Terraform uses configuration, state, and provider information to determine the required changes.

---

# 📌 Terraform Resource Address

A Terraform resource has an address.

For example:

```hcl
resource "azurerm_resource_group" "demo" {
```

The resource address is:

```text
azurerm_resource_group.demo
```

It consists of:

```text
Resource Type
     +
Local Name
```

Example:

```text
azurerm_resource_group
          +
        demo
```

---

# 🔍 Terraform State Commands

## 1. List Resources

```powershell
terraform state list
```

This displays resources currently tracked by Terraform State.

Example:

```text
azurerm_resource_group.demo
```

---

## 2. Show Resource State

```powershell
terraform state show azurerm_resource_group.demo
```

This displays detailed information about the resource stored in Terraform State.

---

## 3. Pull State

```powershell
terraform state pull
```

This displays the current Terraform State in JSON format.

---

## 4. Remove Resource From State

```powershell
terraform state rm <resource-address>
```

Example:

```powershell
terraform state rm azurerm_resource_group.demo
```

This removes the resource from Terraform State.

It does not normally delete the actual Azure resource.

> Use this command carefully.

---

# ⚠️ Terraform State Should Not Be Edited Manually

Do not manually modify:

```text
terraform.tfstate
```

Terraform State should be managed using Terraform commands and appropriate state-management workflows.

---

# 🔥 State Drift

State or configuration drift can occur when infrastructure is changed outside Terraform.

Example:

```text
Terraform
   ↓
environment = dev
```

Someone manually changes the Azure resource:

```text
Azure Portal
   ↓
environment = production
```

Now the actual infrastructure differs from the Terraform configuration.

Conceptually:

```text
Terraform Configuration
        ↓
       dev

Azure Infrastructure
        ↓
   production
```

Terraform can identify differences during planning/reconciliation and may propose changes to bring the infrastructure back toward the configured desired state.

---

# 🧪 Drift Testing

After applying the Terraform configuration:

1. Open Azure Portal.
2. Find:

```text
rg-nikhil-day4
```

3. Change one of its tags manually.
4. Return to the Terraform directory.
5. Run:

```powershell
terraform plan
```

6. Review the proposed changes.

Do not immediately run `terraform apply`.

The purpose of this exercise is to understand how Terraform identifies infrastructure differences.

---

# 📥 Terraform Import

Terraform Import allows existing infrastructure to be brought under Terraform management.

Conceptually:

```text
Existing Azure Resource
          ↓
   Terraform Import
          ↓
   Terraform State
```

Classic import command:

```powershell
terraform import <resource-address> <resource-id>
```

Example:

```powershell
terraform import azurerm_resource_group.demo /subscriptions/<subscription-id>/resourceGroups/<resource-group-name>
```

The resource must also have a corresponding Terraform configuration.

> Import adds an existing resource to Terraform State. It does not automatically generate a complete Terraform configuration for the resource.

---

# 💾 Local State

Currently, our Terraform project uses local state:

```text
Developer Computer
       ↓
terraform.tfstate
```

This is suitable for learning and small individual projects.

However, it is not ideal for a team environment.

---

# ☁️ Remote State

In a team environment, Terraform State is usually stored in a remote backend.

For Azure, we can use:

```text
Terraform
    ↓
Azure Storage Account
    ↓
Blob Container
    ↓
Terraform State
```

Benefits include:

* Centralized state
* Team access
* Better state management
* State locking capabilities
* Better support for CI/CD

Remote State will be covered in a later day.

---

# 🔐 Terraform State and Git

Do not commit:

```text
terraform.tfstate
terraform.tfstate.backup
```

Add the following to `.gitignore`:

```gitignore
*.tfstate
*.tfstate.*
```

Terraform State can contain infrastructure information and potentially sensitive data.

---

# 🛠️ Commands Used in Day 4

Initialize:

```powershell
terraform init
```

Format:

```powershell
terraform fmt
```

Validate:

```powershell
terraform validate
```

Plan:

```powershell
terraform plan
```

Apply:

```powershell
terraform apply
```

List State:

```powershell
terraform state list
```

Show State:

```powershell
terraform state show azurerm_resource_group.demo
```

Pull State:

```powershell
terraform state pull
```

Destroy:

```powershell
terraform destroy
```

---

# 🎤 Interview Questions & Answers

## Q1. What is Terraform State?

Terraform State is a record Terraform uses to track and manage infrastructure resources.

---

## Q2. What is `terraform.tfstate`?

`terraform.tfstate` is the default local state file where Terraform stores information about infrastructure it manages.

---

## Q3. Why is Terraform State important?

Terraform uses State to maintain the relationship between Terraform configuration and real infrastructure.

It helps Terraform determine what resources exist and what changes are required.

---

## Q4. Should Terraform State be stored in Git?

Generally, no.

Terraform State can contain sensitive information and should normally be stored securely in a remote backend for team environments.

---

## Q5. What is State Drift?

State or configuration drift occurs when the actual infrastructure changes outside the normal Terraform workflow and becomes different from the expected configuration.

---

## Q6. What does `terraform state list` do?

It lists all resources currently tracked by Terraform State.

---

## Q7. What does `terraform state show` do?

It displays detailed information about a specific resource stored in Terraform State.

Example:

```powershell
terraform state show azurerm_resource_group.demo
```

---

## Q8. What does `terraform state rm` do?

It removes a resource from Terraform State without normally deleting the actual infrastructure.

---

## Q9. What is Terraform Import?

Terraform Import associates an existing infrastructure resource with a Terraform resource and records it in Terraform State.

---

## Q10. Does Terraform Import create the resource?

No.

Import is used for an existing resource. It brings that resource under Terraform State management.

---

## Q11. What is Remote State?

Remote State means storing Terraform State in a remote backend instead of keeping it only on the local machine.

---

## Q12. Why is Remote State useful?

Remote State provides centralized access to State and is useful for teams and CI/CD systems.

---

## Q13. What is the difference between Terraform configuration and Terraform State?

Terraform configuration describes the desired infrastructure.

Terraform State records Terraform's knowledge of the infrastructure it manages.

```text
.tf files
   ↓
Desired Configuration

.tfstate
   ↓
Terraform State
```

---

## Q14. What happens when someone changes an Azure resource manually?

Terraform can detect differences between the desired configuration and the infrastructure during planning/reconciliation and may propose changes to bring the infrastructure back toward the configured state.

---

## Q15. What is a Terraform Resource Address?

A resource address uniquely identifies a resource in Terraform configuration and State.

Example:

```text
azurerm_resource_group.demo
```

---

# 🔥 Scenario-Based Interview Questions

## Q16. A developer manually deletes an Azure resource that Terraform manages. What happens?

The actual infrastructure no longer matches Terraform's expected state.

During the next Terraform planning/reconciliation process, Terraform can detect that the managed resource is missing and may propose recreating it according to the configuration.

---

## Q17. An Azure resource already exists, but it was created manually. How can you manage it with Terraform?

I would first define the corresponding Terraform resource configuration and then import the existing Azure resource into Terraform State.

Example:

```powershell
terraform import <resource-address> <resource-id>
```

After import, I would run:

```powershell
terraform plan
```

and make the Terraform configuration match the actual resource.

---

## Q18. Why shouldn't we manually edit `terraform.tfstate`?

Terraform State is structured data used internally by Terraform. Manual changes can cause inconsistencies between Terraform State and real infrastructure.

State should be managed using Terraform's state commands and proper backend/state-management procedures.

---

# 🎯 Day 4 Checklist

* [x] Understand Terraform State
* [x] Understand `terraform.tfstate`
* [x] Understand desired vs actual infrastructure
* [x] Understand resource addresses
* [x] Use `terraform state list`
* [x] Use `terraform state show`
* [x] Use `terraform state pull`
* [x] Understand `terraform state rm`
* [x] Understand State Drift
* [x] Understand Terraform Import
* [x] Understand Local State
* [x] Understand Remote State
* [x] Understand Git and State best practices
* [x] Practice State-related interview questions

---

# 🚀 Next — Day 5

Day 5 will go deeper into **Terraform State Operations and Remote State**.

Topics:

```text
Terraform State Operations
        ↓
terraform state mv
        ↓
terraform state rm
        ↓
Terraform Import
        ↓
Import Blocks
        ↓
State Migration
        ↓
Azure Storage Account
        ↓
Remote Backend
        ↓
State Locking
```

The goal is to move from **basic local Terraform State** to **real-world Azure Terraform State management**.
