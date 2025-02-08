data "azurerm_client_config" "current" {}

provider "azurerm" {
  # required
  features {}
  subscription_id = "bd0c7cfc-3ab2-4b18-a4f2-61ed98b89601"
}

provider "github" {
  # We use `gh auth login` instead
  #token = var.github_token
  owner = var.github_organisation
}

provider "juicefs" {}

resource "azurerm_resource_group" "identity" {
  name     = "${var.prefix}-identity"
  location = var.location
}

resource "azurerm_user_assigned_identity" "github" {
  #for_each            = var.use_managed_identity ? { for env in var.environments : env => env } : {}
  location            = var.location
  #name                = "${var.prefix}-${each.value}"
  name                = var.prefix
  resource_group_name = azurerm_resource_group.identity.name
}

resource "azurerm_federated_identity_credential" "github" {
  #for_each            = var.use_managed_identity ? { for env in var.environments : env => env } : {}
  name                = "${var.github_organisation}-${var.github_repository}"
  resource_group_name = azurerm_resource_group.identity.name
  audience            = [local.default_audience_name]
  issuer              = local.github_issuer_url
  #parent_id           = azurerm_user_assigned_identity.github[each.value].id
  parent_id           = azurerm_user_assigned_identity.github.id
  #subject             = "repo:${var.github_organisation}/${var.github_repository}:environment:${each.value}"
  # wildcard, everything, you need the `:*` at the end, if you don't have this then you'll get rejected.
  #subject             = "repo:${var.github_organisation}/${var.github_repository}:*"
  # Main branch
  subject             = "repo:${var.github_organisation}/${var.github_repository}:ref:refs/heads/main"
}

data "github_repository" "repo" {
  full_name = "${var.github_organisation}/${var.github_repository}"
}

resource "github_actions_secret" "azure_subscription_id" {
  repository       = data.github_repository.repo.name
  secret_name      = "AZURE_SUBSCRIPTION_ID"
  plaintext_value  = data.azurerm_client_config.current.subscription_id
}

resource "github_actions_secret" "azure_tenant_id" {
  repository       = data.github_repository.repo.name
  secret_name      = "AZURE_TENANT_ID"
  plaintext_value  = data.azurerm_client_config.current.tenant_id
}

resource "github_actions_secret" "azure_client_id" {
  repository       = data.github_repository.repo.name
  secret_name      = "AZURE_CLIENT_ID"
  plaintext_value  = azurerm_user_assigned_identity.github.client_id
}

## XXX TODO
# Need to setup role assignments
# In GitHub my Azure workflow couldn't authenticate until the managed identity has been assigned a role.
# I gave it Reader to itself manually in the Azure Portal
# But I need to give it the appropriate assignments in Terraform

resource "azurerm_storage_account" "kubler" {
  # The name is globally unique in all of Azure
  name                     = "${lower(replace(var.prefix, "-", ""))}"
  resource_group_name      = azurerm_resource_group.identity.name
  location                 = var.location
  account_tier             = "Standard"
  # LRS is cheapest
  account_replication_type = "LRS"
}

# An Azure Storage Container is the equivalent of an AWS S3 Bucket
resource "azurerm_storage_container" "packages" {
  #for_each              = { for env in var.environments : env => env }
  #name                  = each.value
  name = "packages"
  #storage_account_name  = azurerm_storage_account.kubler.name
  storage_account_id     = azurerm_storage_account.kubler.id
  container_access_type  = "private"
}

resource "azurerm_redis_cache" "juicefs" {
  name = "juicefs"
  location = var.location
  resource_group_name = azurerm_resource_group.identity.name
  capacity = 0
  family = "C"
  #sku_name = "Basic"
  sku_name = "Standard"
}

resource "github_actions_secret" "azure_storage_account" {
  repository       = data.github_repository.repo.name
  secret_name      = "AZURE_STORAGE_ACCOUNT"
  plaintext_value  = azurerm_storage_account.kubler.name
}

resource "github_actions_secret" "azure_storage_container" {
  repository       = data.github_repository.repo.name
  secret_name      = "AZURE_STORAGE_CONTAINER"
  plaintext_value  = azurerm_storage_container.packages.name
}

resource "azurerm_role_assignment" "storage_container" {
  #for_each             = { for env in var.environments : env => env }
  //scope                = azurerm_storage_container.packages.resource_manager_id
  scope                = azurerm_storage_container.packages.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = azurerm_user_assigned_identity.github.principal_id
}

resource "azurerm_role_assignment" "storage_account" {
  #for_each             = { for env in var.environments : env => env }
  scope                = azurerm_storage_account.kubler.id
  #role_definition_name = "Reader"
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.github.principal_id
}

# Without this:
#   - Can NOT list storage accounts or containers
#   - But can list and upload blobs by using account name and container name
resource "azurerm_role_assignment" "resource_group" {
  #for_each             = { for env in var.environments : env => env }
  scope                = azurerm_resource_group.identity.id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.github.principal_id
}

data "juicefs_version" "juicefs" {}


output "juicefs_version" {
  value = data.juicefs_version.juicefs.version
}
