# Terraform Day 3 — Expressions, Functions, count & for_each

## 📋 Agenda

* Terraform expressions
* String interpolation
* Terraform functions
* Conditional expressions
* `count`
* `for_each`
* `each.key` and `each.value`
* `for` expressions
* `count` vs `for_each`
* Creating multiple Azure resources dynamically
* Interview-focused questions and answers

---

# 🎯 About Day 3

Day 3 focuses on making Terraform configurations **dynamic**.

In previous days, we created Azure resources using variables and static configuration.

In Day 3, we learn how Terraform can dynamically calculate values and create multiple resources using:

* Expressions
* Functions
* Conditional expressions
* `count`
* `for_each`
* `for` expressions

These concepts are important for writing reusable and scalable Terraform configurations.

---

# 🎯 Purpose of Day 3

The purpose of Day 3 is to understand how Terraform can dynamically generate infrastructure instead of manually defining every resource.

For example, instead of writing three separate Resource Groups:

```text
rg-nikhil-dev
rg-nikhil-qa
rg-nikhil-prod
```

we can use `for_each`:

```hcl
for_each = var.environments
```

Terraform can then create all required resources automatically.

---

# 📁 Project Structure

```text
day_3/
│
├── main.tf
├── variables.tf
├── terraform.tfvars
├── outputs.tf
├── locals.tf
├── README.md
└── .terraform.lock.hcl
```

Generated files/directories:

```text
.terraform/
terraform.tfstate
terraform.tfstate.backup
```

These should normally not be committed to Git.

---

# ⚙️ Configuration

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

The AzureRM provider allows Terraform to communicate with Azure and manage Azure resources.

---

# 2. Terraform Variables

`variables.tf`:

```hcl
variable "location" {
  description = "Default Azure region"
  type        = string
}

variable "environments" {
  description = "Environment names and Azure regions"

  type = map(string)
}
```

The `environments` variable contains multiple environment names and their corresponding Azure regions.

---

# 3. terraform.tfvars

Example:

```hcl
location = "Central India"

environments = {
  dev  = "Central India"
  qa   = "Central India"
  prod = "Central India"
}
```

For learning purposes, all environments can use the same Azure region.

---

# 4. Terraform Locals

`locals.tf`:

```hcl
locals {
  project_name = "terraform-learning"

  common_tags = {
    project    = local.project_name
    managed_by = "terraform"
    owner      = "nikhil"
  }
}
```

Locals allow us to define reusable values.

---

# 5. Terraform Expressions

Terraform expressions are used to calculate or produce values.

Example:

```hcl
name = "rg-${var.environment}"
```

If:

```text
environment = "dev"
```

Terraform produces:

```text
rg-dev
```

This is called string interpolation.

---

# 6. Terraform Functions

Terraform provides built-in functions that can transform or calculate values.

Common functions include:

```text
lower()
upper()
length()
join()
split()
replace()
contains()
lookup()
toset()
tomap()
```

Example:

```hcl
name = lower(var.project_name)
```

If:

```text
Terraform-Learning
```

is provided, the result becomes:

```text
terraform-learning
```

---

# 7. Conditional Expressions

Terraform supports conditional expressions using:

```text
condition ? true_value : false_value
```

Example:

```hcl
locals {
  environment_type = var.environment == "prod" ? "production" : "non-production"
}
```

If:

```text
environment = "prod"
```

the result is:

```text
production
```

Otherwise:

```text
non-production
```

---

# 8. count

`count` is used to create multiple instances of a resource.

Example:

```hcl
resource "azurerm_resource_group" "demo" {
  count = 3

  name     = "rg-nikhil-${count.index + 1}"
  location = var.location

  tags = local.common_tags
}
```

This creates:

```text
rg-nikhil-1
rg-nikhil-2
rg-nikhil-3
```

Terraform provides the current numeric index using:

```hcl
count.index
```

The index starts from:

```text
0
```

Therefore:

```hcl
count.index + 1
```

produces:

```text
1
2
3
```

---

# 9. for_each

`for_each` is used to create multiple resource instances from a set or map.

Example:

```hcl
resource "azurerm_resource_group" "environment" {
  for_each = var.environments

  name     = "rg-nikhil-${each.key}"
  location = each.value

  tags = {
    environment = each.key
    managed_by  = "terraform"
  }
}
```

If the variable contains:

```hcl
environments = {
  dev  = "Central India"
  qa   = "Central India"
  prod = "Central India"
}
```

Terraform creates:

```text
rg-nikhil-dev
rg-nikhil-qa
rg-nikhil-prod
```

---

# 10. each.key

`each.key` represents the current key when using `for_each`.

For:

```hcl
environments = {
  dev  = "Central India"
  qa   = "Central India"
  prod = "Central India"
}
```

we get:

```text
each.key
```

as:

```text
dev
qa
prod
```

---

# 11. each.value

`each.value` represents the current value.

For:

```hcl
environments = {
  dev  = "Central India"
  qa   = "Central India"
  prod = "Central India"
}
```

we get:

```text
each.value
```

as:

```text
Central India
Central India
Central India
```

---

# 12. for Expressions

A `for` expression can transform a collection into another collection.

Example:

```hcl
locals {
  environment_names = [
    for environment in keys(var.environments) :
    upper(environment)
  ]
}
```

Input:

```text
dev
qa
prod
```

Output:

```text
DEV
QA
PROD
```

---

# 13. count vs for_each

This is an important Terraform interview topic.

| `count`                          | `for_each`                             |
| -------------------------------- | -------------------------------------- |
| Uses numeric indexes             | Uses keys                              |
| Uses `count.index`               | Uses `each.key` / `each.value`         |
| Good for identical resources     | Good for uniquely identified resources |
| Uses a number                    | Uses a map or set                      |
| Resource identity is index-based | Resource identity is key-based         |

### Simple rule

Use:

```text
count
```

when you need a fixed number of similar resources.

Use:

```text
for_each
```

when each resource has a meaningful identity or different configuration.

---

# 🧪 Hands-on Example

## variables.tf

```hcl
variable "environments" {
  description = "Environment names and Azure regions"

  type = map(string)
}
```

---

## terraform.tfvars

```hcl
environments = {
  dev  = "Central India"
  qa   = "Central India"
  prod = "Central India"
}
```

---

## main.tf

```hcl
resource "azurerm_resource_group" "environment" {
  for_each = var.environments

  name     = "rg-nikhil-${each.key}"
  location = each.value

  tags = {
    environment = each.key
    managed_by  = "terraform"
  }
}
```

Terraform will create:

```text
rg-nikhil-dev
rg-nikhil-qa
rg-nikhil-prod
```

---

# 🔄 Terraform Workflow

Run the following commands:

```powershell
terraform fmt
```

Format the Terraform code.

```powershell
terraform init
```

Initialize the Terraform project and download providers.

```powershell
terraform validate
```

Validate the Terraform configuration.

```powershell
terraform plan
```

Review the resources Terraform intends to create.

```powershell
terraform apply
```

Apply the configuration to Azure.

---

# 🧠 Important Concepts

```text
Expression
    ↓
Calculate / Generate a value

Function
    ↓
Transform / Calculate a value

Conditional
    ↓
Choose between two values

count
    ↓
Create multiple indexed resources

for_each
    ↓
Create multiple identified resources

for expression
    ↓
Transform collections
```

---

# 🎤 Interview Questions & Answers

## Q1. What is a Terraform expression?

A Terraform expression is used to calculate or produce a value that can be used by Terraform configuration.

Example:

```hcl
name = "rg-${var.environment}"
```

---

## Q2. What is string interpolation in Terraform?

String interpolation allows Terraform expressions to be embedded inside strings.

Example:

```hcl
name = "rg-${var.environment}"
```

If the environment is `dev`, the result is:

```text
rg-dev
```

---

## Q3. What is `count` in Terraform?

`count` is a meta-argument that allows Terraform to create multiple instances of a resource based on a numeric value.

Example:

```hcl
count = 3
```

---

## Q4. What is `count.index`?

`count.index` represents the numeric index of the current resource instance.

Example:

```hcl
name = "server-${count.index}"
```

---

## Q5. What is `for_each`?

`for_each` is a Terraform meta-argument that creates multiple resource instances from a map or set.

Example:

```hcl
for_each = var.environments
```

---

## Q6. What are `each.key` and `each.value`?

When using `for_each`:

```text
each.key
```

represents the current key.

```text
each.value
```

represents the current value.

---

## Q7. What is the difference between `count` and `for_each`?

`count` uses numeric indexes and is useful when creating a fixed number of similar resources.

`for_each` uses keys and values and is better when resources have meaningful identities or different configurations.

---

## Q8. Why can `for_each` be better than `count`?

`for_each` gives resources stable identities based on keys.

For example:

```text
dev
qa
prod
```

If one environment is removed, the remaining resources can retain their identities instead of being shifted because of numeric indexes.

---

## Q9. What is a Terraform function?

A Terraform function is a built-in operation used to transform or calculate values.

Examples:

```text
lower()
upper()
length()
join()
split()
replace()
```

---

## Q10. What is a conditional expression?

A conditional expression selects one of two values based on a condition.

Syntax:

```text
condition ? true_value : false_value
```

Example:

```hcl
var.environment == "prod" ? "production" : "non-production"
```

---

# 🔥 Scenario-Based Interview Questions

## Q11. You need to create 10 identical Azure VMs. Which would you consider?

For a simple fixed number of identical resources, `count` can be appropriate.

Example:

```hcl
count = 10
```

However, if each VM has a meaningful identity or different configuration, I would consider `for_each`.

---

## Q12. You have Dev, QA, and Production environments with different Azure regions. Which approach would you use?

I would use `for_each` with a map.

Example:

```hcl
environments = {
  dev  = "Central India"
  qa   = "East US"
  prod = "West Europe"
}
```

Then:

```hcl
for_each = var.environments
```

and:

```hcl
location = each.value
```

This allows each environment to have its own configuration.

---

## Q13. What happens if an item is removed from a `for_each` map?

Terraform identifies resources by their keys.

For example:

```text
dev
qa
prod
```

If `qa` is removed, Terraform identifies the `qa` resource as no longer being part of the desired configuration and plans to destroy that specific instance.

The `dev` and `prod` instances retain their keys.

---

# 🎯 Day 3 Checklist

* [x] Terraform expressions
* [x] String interpolation
* [x] Terraform functions
* [x] Conditional expressions
* [x] `count`
* [x] `count.index`
* [x] `for_each`
* [x] `each.key`
* [x] `each.value`
* [x] `for` expressions
* [x] `count` vs `for_each`
* [x] Dynamic Azure Resource Groups
* [x] Scenario-based interview questions

---

# 🚀 Next — Day 4

Day 4 will focus on one of the most important Terraform topics:

```text
Terraform State
      ↓
terraform.tfstate
      ↓
State Management
      ↓
State Commands
      ↓
Terraform Import
      ↓
State Drift
      ↓
Remote State
      ↓
Azure Storage Backend
```

The goal will be to understand **how Terraform knows what infrastructure already exists and how state is managed in real-world projects**.
