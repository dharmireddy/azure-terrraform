terraform {
  required_version = ">= 0.13"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.23.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.4.3"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "Azure-Pipeline" {
  name     = "Azure-pipelineRG"
  location = "West Europe"
}

resource "azurerm_virtual_network" "PipelineVnet" {
  name                = "PipelineVnet"
  address_space       = ["10.0.0.0/16"]
  location            = "West Europe"
  resource_group_name = azurerm_resource_group.Azure-Pipeline.name
}

resource "azurerm_subnet" "PipelineSubnet" {
  name                 = "PipelineSubnet"
  resource_group_name  = azurerm_resource_group.Azure-Pipeline.name
  virtual_network_name = azurerm_virtual_network.PipelineVnet.name
  address_prefixes     = ["10.0.2.0/24"]
  service_endpoints    = ["Microsoft.Sql", "Microsoft.Storage"]
}

resource "azurerm_storage_account" "PipelineStorageAccount" {
  name                = "PipelineStorageAccount"
  resource_group_name = azurerm_resource_group.Azure-Pipeline.name

  location                 = "West Europe"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  network_rules {
    default_action             = "Deny"
    ip_rules                   = ["100.0.0.1"]
    virtual_network_subnet_ids = [azurerm_subnet.PipelineSubnet.id]
  }

  tags = {
    environment = "staging"
  }
}