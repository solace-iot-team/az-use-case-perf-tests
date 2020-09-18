# Configure the Azure Provider
provider "azurerm" {
  version = "=2.0.0"

  features {}
}

# Create a resource group
resource "azurerm_resource_group" "sdkperf_az_resgrp" {
  count = var.az_resgrp_name == "" ? 1 : 0

  name     = "${var.tag_name_prefix}-sdkperf_resgrp"
  location = var.az_region
}

#Query the AZ Res Group location for the specified AZ Res Group Name
data "azurerm_resource_group" "input_resgroup" {
  count = var.az_resgrp_name == "" ? 0 : 1
  
  name = var.az_resgrp_name
}


