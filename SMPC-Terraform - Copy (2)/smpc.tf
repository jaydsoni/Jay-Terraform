# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }
  
  backend "remote" {
    organization = "InvestorCOM"

    workspaces {
      name = "SMPC"
    }
  }
}
 
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-terraform-learning-smpc"
  location = "CanadaCentral"

  tags = {
    "Env" = "Terraform Getting Started"
    "Team" = "DevOps"
  }
}

resource "azurerm_signalr_service" "terraform" {
  name = "sr-terraform"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  sku {
    capacity = 1
    name = "Free_F1"
  }
}

resource "azurerm_app_service_plan" "example" {
  name                = "api-appserviceplan-lern"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "api" {
  name = "api-smpc"
  app_service_plan_id = azurerm_app_service_plan.example.id
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  site_config {
    dotnet_framework_version = "v4.0"
    linux_fx_version = "DOTNETCORE|3.1"
  }
}

resource "azurerm_app_service" "blazor" {
  name = "blazor-smpc"
  app_service_plan_id = azurerm_app_service_plan.example.id
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  site_config {
    dotnet_framework_version = "v4.0"
    linux_fx_version = "DOTNETCORE|3.1"
  }
}

##SQL Server
resource "azurerm_sql_server" "sqlserver"{
  name="terraformsqlserverjd"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  version = "12.0"
  administrator_login = "adminjdsoni"
  administrator_login_password = "$password1"
}

resource "azurerm_storage_account" "example" {
  name                     = "examplesajd"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_sql_database" "example" {
  name                = "myexamplesqldatabase"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  server_name         = azurerm_sql_server.sqlserver.name

  extended_auditing_policy {
    storage_endpoint                        = azurerm_storage_account.example.primary_blob_endpoint
    storage_account_access_key              = azurerm_storage_account.example.primary_access_key
    storage_account_access_key_is_secondary = true
    retention_in_days                       = 6
  }



  tags = {
    environment = "production"
  }
}

##Azure VM
resource "azurerm_virtual_network" "tvnet" {
  name  = "terraform-vnet"
  address_space = [ "10.0.0.0/16" ]
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
}

resource "azurerm_subnet" "tsub" {
  name = "terraformsubnet"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.tvnet.name
  address_prefixes = [ "10.0.1.0/24" ]
}

resource "azurerm_network_interface" "tni" {
  name = "terraformnetworkinterface"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name = "terraformpoc"
    subnet_id = azurerm_subnet.tsub.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "tvm" {
  name = "TerraformVM"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  size = "Standard_F2"
  admin_password = "$password1110"
  admin_username = "adminjay"
  network_interface_ids = [ azurerm_network_interface.tni.id, ]
  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}