# Day 5 — Terraform Remote State & Azure Backend

## 📌 Agenda

* Terraform State recap
* Local State vs Remote State
* Terraform Backend
* Azure Storage Account
* Azure Blob Container
* AzureRM Backend
* Remote State configuration
* State migration
* State locking
* State security
* Hands-on implementation
* Interview questions
* Day 5 checklist

---

# 1. About Day 5

In Day 4, we learned about Terraform State and how Terraform uses the `terraform.tfstate` file to track infrastructure.

In Day 5, we move from **local state** to **remote state** using an Azure Storage Account.

The main architecture is:

```text
Developer
    |
    v
Terraform
    |
    v
AzureRM Backend
    |
    v
Azure Storage Account
    |
    v
Blob Container
    |
    v
Terraform State
```

---

# 2. Purpose of Day 5

The main goals of Day 5 are:

* Understand Terraform Remote State
* Understand Terraform Backends
* Configure Azure as a Terraform Backend
* Store Terraform State in Azure Blob Storage
* Understand State Locking
* Understand State Security
* Learn how remote state supports team collaboration

---

# 3. Day 5 Folder Structure

Each learning day is maintained as an independent Terraform configuration.

```text
D:\azure\terraform
│
├── day_1
├── day_2
├── day_3
├── day_4
├── day_5
│   ├── main.tf
│   ├── variables.tf
│   ├── terraform.tfvars
│   ├── outputs.tf
│   ├── backend.tf
│   └── README.md
│
└── .gitignore
```

We intentionally keep each day independent to understand Terraform concepts step by step.

---

# 4. Local State

By default, Terraform can store state locally.

```text
Terraform
    |
    v
terraform.tfstate
    |
    v
Local Machine
```

The state file contains information that Terraform uses to track managed infrastructure.

Example resource address:

```text
azurerm_resource_group.demo
```

---

# 5. Problems With Local State

Local state can become difficult to manage when multiple developers work on the same infrastructure.

Example:

```text
Developer A → Local State
Developer B → Local State
Developer C → Local State
```

Possible problems include:

* Different state files
* State synchronization problems
* Difficult team collaboration
* Concurrent changes
* State locking requirements
* Risk of losing local state

For team environments, remote state is commonly used.

---

# 6. Remote State

Remote State stores the Terraform state in a shared remote location.

For Azure:

```text
Developer A ─┐
Developer B ─┼──> Azure Storage Account
Developer C ─┘          |
                         v
                   Terraform State
```

This provides a centralized location for Terraform state.

---

# 7. Terraform Backend

A Terraform backend determines where Terraform stores its state.

Examples:

```text
local
azurerm
s3
gcs
```

For Azure, we use:

```hcl
backend "azurerm"
```

---

# 8. Azure Remote State Architecture

Our Day 5 setup:

```text
Azure
 |
 +-- Resource Group
 |      rg-terraform-state
 |
 +-- Storage Account
 |      stterraformday5xxxx
 |
 +-- Blob Container
        tfstate
          |
          +-- day5.tfstate
```

---

# 9. Backend Infrastructure

The backend storage must exist before Terraform can use it as its backend.

The flow is:

```text
Create Resource Group
        |
        v
Create Storage Account
        |
        v
Create Blob Container
        |
        v
Configure AzureRM Backend
        |
        v
Terraform Remote State
```

This initial infrastructure is commonly referred to as bootstrap infrastructure.

---

# 10. Create the Day 5 Directory

Open PowerShell:

```powershell
cd D:\azure\terraform
```

Create the directory:

```powershell
mkdir day_5
```

Move into it:

```powershell
cd day_5
```

Verify:

```powershell
pwd
```

Expected:

```text
D:\azure\terraform\day_5
```

---

# 11. Create Backend Resource Group

Create the Azure Resource Group:

```powershell
az group create `
  --name rg-terraform-state `
  --location centralindia
```

Verify:

```powershell
az group show --name rg-terraform-state
```

---

# 12. Create Storage Account

Storage Account names must be globally unique.

Example:

```powershell
az storage account create `
  --name stterraformday5nikhil `
  --resource-group rg-terraform-state `
  --location centralindia `
  --sku Standard_LRS
```

If the name is already taken, use another unique name.

Example:

```text
stterraformday5nikhil01
stterraformday5nikhil02
```

---

# 13. Create Blob Container

Create the `tfstate` container:

```powershell
az storage container create `
  --name tfstate `
  --account-name stterraformday5nikhil `
  --auth-mode login
```

The final structure becomes:

```text
rg-terraform-state
        |
        v
stterraformday5nikhil
        |
        v
tfstate
```

---

# 14. backend.tf

Create a file named:

```text
backend.tf
```

Configuration:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "stterraformday5nikhil"
    container_name       = "tfstate"
    key                  = "day5.tfstate"
  }
}
```

---

# 15. Backend Configuration

| Property               | Description                                   |
| ---------------------- | --------------------------------------------- |
| `resource_group_name`  | Resource Group containing the Storage Account |
| `storage_account_name` | Azure Storage Account                         |
| `container_name`       | Blob Container                                |
| `key`                  | Terraform state object name                   |

For example:

```hcl
key = "day5.tfstate"
```

means our state is stored using:

```text
day5.tfstate
```

inside the configured Blob Container.

---

# 16. main.tf

Create `main.tf`:

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

resource "azurerm_resource_group" "demo" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    environment = var.environment
    managed_by  = "terraform"
    day         = "day5"
  }
}
```

---

# 17. variables.tf

Create `variables.tf`:

```hcl
variable "resource_group_name" {
  description = "Name of the application Resource Group"
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

# 18. terraform.tfvars

Create `terraform.tfvars`:

```hcl
resource_group_name = "rg-nikhil-day5"
location             = "Central India"
environment          = "dev"
```

Notice that this Resource Group is different from:

```text
rg-terraform-state
```

The first one contains our Terraform backend.

The second one is the infrastructure managed by our Day 5 Terraform configuration.

---

# 19. outputs.tf

Create `outputs.tf`:

```hcl
output "resource_group_name" {
  description = "Name of the Resource Group"
  value       = azurerm_resource_group.demo.name
}

output "resource_group_id" {
  description = "ID of the Resource Group"
  value       = azurerm_resource_group.demo.id
}
```

---

# 20. Terraform Initialization

Run:

```powershell
terraform init
```

Terraform initializes:

* Provider plugins
* Backend
* Terraform working directory

Expected output will contain something similar to:

```text
Initializing the backend...
Initializing provider plugins...
Terraform has been successfully initialized!
```

---

# 21. Format

Run:

```powershell
terraform fmt
```

This formats Terraform configuration files.

---

# 22. Validate

Run:

```powershell
terraform validate
```

Expected:

```text
Success! The configuration is valid.
```

---

# 23. Plan

Run:

```powershell
terraform plan
```

Terraform will calculate the changes before applying them.

Expected resource:

```text
azurerm_resource_group.demo
```

---

# 24. Apply

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
rg-nikhil-day5
```

---

# 25. Check Terraform State

Run:

```powershell
terraform state list
```

Expected:

```text
azurerm_resource_group.demo
```

We can inspect the resource:

```powershell
terraform state show azurerm_resource_group.demo
```

---

# 26. Remote State Flow

After configuring the backend:

```text
Terraform
    |
    v
AzureRM Backend
    |
    v
Azure Storage Account
    |
    v
Blob Container
    |
    v
day5.tfstate
```

This is the main concept of Day 5.

---

# 27. State Locking

State locking helps prevent multiple Terraform operations from modifying the same state simultaneously.

Example:

```text
Developer A
    |
terraform apply
    |
    v
State Locked
```

At the same time:

```text
Developer B
    |
terraform apply
    |
    v
Cannot safely modify the same state
```

The AzureRM backend uses Azure Storage capabilities to coordinate access to the state.

---

# 28. Local State vs Remote State

| Feature               | Local State   | Remote State   |
| --------------------- | ------------- | -------------- |
| Storage               | Local machine | Remote backend |
| Team collaboration    | Difficult     | Better         |
| Centralized state     | No            | Yes            |
| State locking         | Limited       | Supported      |
| Shared infrastructure | Difficult     | Easier         |
| Azure Storage         | Not required  | Can be used    |

---

# 29. State Migration

Suppose you already have:

```text
terraform.tfstate
```

locally.

Then you configure:

```hcl
backend "azurerm" {
  ...
}
```

Terraform can migrate the existing state to the remote backend during initialization.

Run:

```powershell
terraform init
```

Terraform may ask whether you want to migrate the existing state.

If the configuration and backend are correct, confirm the migration.

Conceptually:

```text
Local State
    |
    v
terraform.tfstate
    |
    v
Remote Backend
    |
    v
Azure Blob Storage
```

---

# 30. State Security

Terraform State should be treated as sensitive infrastructure data.

Do not commit:

```text
terraform.tfstate
```

to Git.

Do not manually edit the state file.

Do not expose the Storage Account publicly just to make Terraform work.

Use appropriate Azure authentication and access controls.

---

# 31. .gitignore

The root `.gitignore` should contain:

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

The `.terraform.lock.hcl` file should generally be committed.

---

# 32. Important Terraform Commands

### Initialize

```powershell
terraform init
```

### Format

```powershell
terraform fmt
```

### Validate

```powershell
terraform validate
```

### Plan

```powershell
terraform plan
```

### Apply

```powershell
terraform apply
```

### List State Resources

```powershell
terraform state list
```

### Show State Resource

```powershell
terraform state show azurerm_resource_group.demo
```

### Destroy

```powershell
terraform destroy
```

---

# 33. Interview Questions

## Q1. What is Terraform State?

Terraform State is the information Terraform uses to track the infrastructure it manages and map Terraform resources to real infrastructure.

---

## Q2. What is Remote State?

Remote State means storing Terraform state in a remote backend instead of storing it only on the local machine.

---

## Q3. Why do we use Remote State?

Common reasons include:

* Team collaboration
* Centralized state
* State locking
* Shared infrastructure management
* Better state management

---

## Q4. What is a Terraform Backend?

A backend defines where Terraform stores its state.

Example:

```hcl
backend "azurerm" {
  ...
}
```

---

## Q5. How can Terraform State be stored in Azure?

Using:

```text
Azure Storage Account
        |
        v
Blob Container
        |
        v
Terraform State
```

with the AzureRM backend.

---

## Q6. What is State Locking?

State locking prevents multiple Terraform operations from modifying the same state at the same time.

---

## Q7. Should Terraform State be committed to Git?

No.

State may contain sensitive infrastructure information and should be managed through an appropriate backend.

---

## Q8. What is the purpose of the `key` property?

Example:

```hcl
key = "day5.tfstate"
```

It identifies the Terraform state object stored in the backend.

---

## Q9. Why should backend infrastructure exist first?

Terraform needs to connect to the backend before it can store its state there.

Therefore, the Storage Account and Blob Container used by the backend need to be available first.

---

## Q10. What is the AzureRM backend?

The AzureRM backend is a Terraform backend that stores Terraform state in Azure Storage.

Example:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "stterraformday5nikhil"
    container_name       = "tfstate"
    key                  = "day5.tfstate"
  }
}
```

---

# 34. Interview Scenario

### Scenario

You have 10 developers working on the same Azure infrastructure. Every developer currently has a local `terraform.tfstate`.

How would you improve the setup?

### Expected Approach

```text
Local Terraform State
        |
        v
Azure Storage Account
        |
        v
Blob Container
        |
        v
AzureRM Backend
        |
        v
Remote Terraform State
        |
        v
Team Collaboration
```

Also implement:

* Proper Azure access control
* Secure authentication
* State locking
* State backup/recovery considerations
* `.gitignore` for local state
* No state files committed to Git

---

# 35. Day 5 Hands-On Checklist

* [ ] Create `day_5`
* [ ] Create backend Resource Group
* [ ] Create Azure Storage Account
* [ ] Create Blob Container
* [ ] Create `backend.tf`
* [ ] Configure AzureRM backend
* [ ] Create `main.tf`
* [ ] Create `variables.tf`
* [ ] Create `terraform.tfvars`
* [ ] Create `outputs.tf`
* [ ] Run `terraform init`
* [ ] Run `terraform fmt`
* [ ] Run `terraform validate`
* [ ] Run `terraform plan`
* [ ] Run `terraform apply`
* [ ] Run `terraform state list`
* [ ] Understand Remote State
* [ ] Understand State Locking
* [ ] Understand State Security
* [ ] Practice interview questions

---

# 36. Day 5 Key Takeaways

The most important concepts to remember are:

```text
Terraform State
      ↓
Backend
      ↓
AzureRM Backend
      ↓
Azure Storage Account
      ↓
Blob Container
      ↓
Remote State
```

Remember:

1. **Local State** → Stored on your machine.
2. **Remote State** → Stored in a remote backend.
3. **Backend** → Defines where Terraform stores state.
4. **AzureRM Backend** → Stores state in Azure Storage.
5. **State Locking** → Helps prevent concurrent state modifications.
6. **State Security** → Protect Terraform state and never commit it to Git.
7. **Backend Infrastructure** → Must be available before Terraform can use it.

---

# 37. Next Day

## Day 6 — Terraform Modules

In Day 6, we will start learning:

```text
Terraform Modules
      |
      +-- main.tf
      +-- variables.tf
      +-- outputs.tf
```

Topics will include:

* What is a module?
* Why use modules?
* Root module
* Child module
* Module inputs
* Module outputs
* Module structure
* Calling a module
* Practical Azure example
* Interview questions
* Real-world use cases
