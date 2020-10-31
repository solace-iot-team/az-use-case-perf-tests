# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# Copyright (c) 2020, Solace Corporation, Jochen Traunecker (jochen.traunecker@solace.com)
# ---------------------------------------------------------------------------------------------

####################################################################################################
# NOTE: The following network resources will only get created if:
# The "sdkperf_secgroup_ids" variable is left "empty"
####################################################################################################

resource "azurerm_network_security_group" "sdkperf_secgrp" {
  name                = "${var.tag_name_prefix}-sdkperf_secgrp"
  location            = var.az_resgrp_name == "" ? azurerm_resource_group.sdkperf_az_resgrp[0].location : data.azurerm_resource_group.input_resgroup[0].location
  resource_group_name = var.az_resgrp_name == "" ? azurerm_resource_group.sdkperf_az_resgrp[0].name : var.az_resgrp_name

  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    Name    = "${var.tag_name_prefix}-sdkperf_secgrp"
    Owner   = var.tag_owner
    Purpose = "sdkperf benchmarking"
    Days    = var.tag_days
  }
}

resource "azurerm_network_security_group" "solacebroker_secgrp" {

  name                = "${var.tag_name_prefix}-solacebroker_secgrp"
  location            = var.az_resgrp_name == "" ? azurerm_resource_group.sdkperf_az_resgrp[0].location : data.azurerm_resource_group.input_resgroup[0].location
  resource_group_name = var.az_resgrp_name == "" ? azurerm_resource_group.sdkperf_az_resgrp[0].name : var.az_resgrp_name

  tags = {
    Name    = "${var.tag_name_prefix}-solacebroker_secgrp"
    Owner   = var.tag_owner
    Purpose = "sdkperf benchmarking"
    Days    = var.tag_days
  }
}

resource "azurerm_network_security_rule" "solbroker-ssh" {
  name                        = "SSH"
  priority                    = 100
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "22"
  source_address_prefix      = "*"
  destination_address_prefix = "*"

  resource_group_name = var.az_resgrp_name == "" ? azurerm_resource_group.sdkperf_az_resgrp[0].name : var.az_resgrp_name
  network_security_group_name = azurerm_network_security_group.solacebroker_secgrp.name
}

resource "azurerm_network_security_rule" "solbroker-sshcli" {
  name                        = "SSH-CLI"
  priority                    = 101
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "2222"
  source_address_prefix      = "*"
  destination_address_prefix = "*"

  resource_group_name = var.az_resgrp_name == "" ? azurerm_resource_group.sdkperf_az_resgrp[0].name : var.az_resgrp_name
  network_security_group_name = azurerm_network_security_group.solacebroker_secgrp.name
}

resource "azurerm_network_security_rule" "solbroker-webportal" {
  name                        = "WebPortal"
  priority                    = 102
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "8080"
  source_address_prefix      = "*"
  destination_address_prefix = "*"

  resource_group_name = var.az_resgrp_name == "" ? azurerm_resource_group.sdkperf_az_resgrp[0].name : var.az_resgrp_name
  network_security_group_name = azurerm_network_security_group.solacebroker_secgrp.name
}
# enable SMF from sdkperf nodes only
resource "azurerm_network_security_rule" "solbroker-msging" {
  name                        = "Messaging"
  priority                    = 103
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "55555"
  source_address_prefix      = "*"
  destination_address_prefix = "*"

  resource_group_name = var.az_resgrp_name == "" ? azurerm_resource_group.sdkperf_az_resgrp[0].name : var.az_resgrp_name
  network_security_group_name = azurerm_network_security_group.solacebroker_secgrp.name
}

# enable web transport for testing with Try-me
resource "azurerm_network_security_rule" "solbroker-webportal" {
  name                        = "WsPlain"
  priority                    = 104
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "8008"
  source_address_prefix      = "*"
  destination_address_prefix = "*"

  resource_group_name = var.az_resgrp_name == "" ? azurerm_resource_group.sdkperf_az_resgrp[0].name : var.az_resgrp_name
  network_security_group_name = azurerm_network_security_group.solacebroker_secgrp.name
}
# enable web transport for testing with Try-me
resource "azurerm_network_security_rule" "solbroker-webportal" {
  name                        = "MqttPlain"
  priority                    = 105
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "1883"
  source_address_prefix      = "*"
  destination_address_prefix = "*"

  resource_group_name = var.az_resgrp_name == "" ? azurerm_resource_group.sdkperf_az_resgrp[0].name : var.az_resgrp_name
  network_security_group_name = azurerm_network_security_group.solacebroker_secgrp.name
}


###
# The End.
