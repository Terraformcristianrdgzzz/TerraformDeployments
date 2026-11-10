terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraformdeployments-state"
    storage_account_name = "sttfstateterraformprac"
    container_name       = "tfstate"
    key                  = "stage/webserver.tfstate"

    use_azuread_auth = true
    use_oidc         = true
  }
}
