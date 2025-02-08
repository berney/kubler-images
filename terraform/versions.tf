terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      #version = "3.110.0"
      version = "~> 4.17"
    }
    azuread = {
      source = "hashicorp/azuread"
      #version = "2.53.1"
      version = "~>3.1"
    }
    github = {
      source  = "integrations/github"
      version = "~> 6.2"
    }
    juicefs = {
      source = "toowoxx/juicefs"
    }
  }
}

