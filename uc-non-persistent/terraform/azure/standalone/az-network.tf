####################################################################################################
# NOTE: The following network resources will only get created if:
# The "subnet_id" variable is left "empty"
####################################################################################################

resource "azurerm_virtual_network" "sdkperf_network" {  
  count = var.subnet_id == "" ? 1 : 0


  name                = "${var.tag_name_prefix}-sdkperf-network"
  address_space       = ["10.0.0.0/16"]
  location            = var.az_resgrp_name == "" ? azurerm_resource_group.sdkperf_az_resgrp[0].location : data.azurerm_resource_group.input_resgroup[0].location
  resource_group_name = var.az_resgrp_name == "" ? azurerm_resource_group.sdkperf_az_resgrp[0].name : var.az_resgrp_name

  tags = {
    Name    = "${var.tag_name_prefix}-sdkperf-network"
    Owner   = var.tag_owner
    Purpose = "sdkperf benchmarking"
    Days    = var.tag_days
  }
}

resource "azurerm_subnet" "sdkperf_subnet" {
  count = var.subnet_id == "" ? 1 : 0

  name                 = "${var.tag_name_prefix}-sdkperf-subnet"
  virtual_network_name = azurerm_virtual_network.sdkperf_network[0].name
  address_prefix       = "10.0.1.0/24"
  resource_group_name  = var.az_resgrp_name == "" ? azurerm_resource_group.sdkperf_az_resgrp[0].name : var.az_resgrp_name

}

