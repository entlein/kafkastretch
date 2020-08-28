provider "azurerm" {
    version= "~>1.5"
}

terraform {
    backend "azurerm" {
      key                  = "aks-terraform.tfstate"
    }
}

# module "network" {
#   source              = "Azure/network/azurerm"
#   version             = "~>2.0"
#   location            = "East US 2"
#   resource_group_name = "rg-kafka"
#   address_space       = "10.1.0.0/16"
#   subnet_names        = ["snet_zk", "snet_yellow", "snet_orange"]
#   subnet_prefixes     = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24" ]
# }