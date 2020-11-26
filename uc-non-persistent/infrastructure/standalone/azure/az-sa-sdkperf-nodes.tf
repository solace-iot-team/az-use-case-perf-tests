
# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# Copyright (c) 2020, Solace Corporation, Jochen Traunecker (jochen.traunecker@solace.com)
# ---------------------------------------------------------------------------------------------


################################################################
# BEGIN: latency node
#
resource "azurerm_linux_virtual_machine" "latency-nodes" {

  count = "1"

  name                   = "${var.tag_name_prefix}-latency-node-${count.index}"
  #If a Resource Group was specified we'll query its Location use it, otherwise use the location of the Res Group that was just created
  location               = var.az_resgrp_name == "" ? azurerm_resource_group.sdkperf_az_resgrp[0].location : data.azurerm_resource_group.input_resgroup[0].location
  resource_group_name    = var.az_resgrp_name == "" ? azurerm_resource_group.sdkperf_az_resgrp[0].name : var.az_resgrp_name

  proximity_placement_group_id = azurerm_proximity_placement_group.sdkperf_az_ppgrp.id

  size                   = var.latency_node_vm_size
  admin_username         = var.az_admin_username
  network_interface_ids  = [azurerm_network_interface.latency-nodes-nic[count.index].id]
  zone                   = var.zone

  source_image_reference {
    publisher = "OpenLogic"
    offer     = "Centos"
    sku       = var.source_image_reference_openlogic_centos_sku
    version   = "latest"
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "${var.tag_name_prefix}-latency-node-${count.index}-OsDisk"
  }
  admin_ssh_key {
    username   = var.az_admin_username
    public_key = file(var.public_key_path)
  }
  tags = {
    Name    = "${var.tag_name_prefix}-latency-node-${count.index}"
    Owner   = var.tag_owner
    Purpose = "sdkperf benchmarking - latency node"
    Days    = var.tag_days
  }

# Do not flag the azurerm_linux_virtual_machine resource as completed, until the VM is able to accept SSH connections, otherwise the Ansible call will fail
  provisioner "remote-exec" {
    inline = [
      "echo 'Latency Node: SSH ready to rock'",
      "echo 'remote-exec: ${self.public_ip_address}, ${var.az_admin_username}, ${var.private_key_path}'"
    ]
    connection {
      agent       = false
      host        = self.public_ip_address
      type        = "ssh"
      user        = var.az_admin_username
      private_key = file(var.private_key_path)
    }
  }
}

resource "azurerm_network_interface" "latency-nodes-nic" {
  count = "1"

  name                   = "${var.tag_name_prefix}-latency-nic-${count.index}"
  location               = var.az_resgrp_name == "" ? azurerm_resource_group.sdkperf_az_resgrp[0].location : data.azurerm_resource_group.input_resgroup[0].location
  resource_group_name    = var.az_resgrp_name == "" ? azurerm_resource_group.sdkperf_az_resgrp[0].name : var.az_resgrp_name
  enable_accelerated_networking = true
  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id == "" ? azurerm_subnet.sdkperf_subnet[0].id : var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.latency-nodes-pubip[count.index].id
  }
  tags = {
    Name    = "${var.tag_name_prefix}-latency-nic-${count.index}"
    Owner   = var.tag_owner
    Purpose = "sdkperf benchmarking - latency node nic"
    Days    = var.tag_days
  }
}

resource "azurerm_public_ip" "latency-nodes-pubip" {
  count = "1"

  name                   = "${var.tag_name_prefix}-latency-pubip-${count.index}"
  location               = var.az_resgrp_name == "" ? azurerm_resource_group.sdkperf_az_resgrp[0].location : data.azurerm_resource_group.input_resgroup[0].location
  resource_group_name    = var.az_resgrp_name == "" ? azurerm_resource_group.sdkperf_az_resgrp[0].name : var.az_resgrp_name
  allocation_method      = "Static"
  sku                    = "Standard"
  zones                   = [var.zone]
  tags = {
    Name    = "${var.tag_name_prefix}-latency-pubip-${count.index}"
    Owner   = var.tag_owner
    Purpose = "sdkperf benchmarking - latency node pubip"
    Days    = var.tag_days
  }
}
#Asociate the VM NIC to the Sec Group created
resource "azurerm_network_interface_security_group_association" "latency-nodes-secgrp_association" {
  count = "1"
  network_interface_id      = azurerm_network_interface.latency-nodes-nic[count.index].id
  network_security_group_id = azurerm_network_security_group.sdkperf_secgrp.id
}
#
# END: latency node
################################################################

################################################################
# BEGIN: publisher node
#
resource "azurerm_linux_virtual_machine" "publisher-nodes" {

  count = "1"

  name                   = "${var.tag_name_prefix}-publisher-node-${count.index}"
  #If a Resource Group was specified we'll query its Location use it, otherwise use the location of the Res Group that was just created
  location               = var.az_resgrp_name == "" ? azurerm_resource_group.sdkperf_az_resgrp[0].location : data.azurerm_resource_group.input_resgroup[0].location
  resource_group_name    = var.az_resgrp_name == "" ? azurerm_resource_group.sdkperf_az_resgrp[0].name : var.az_resgrp_name

  proximity_placement_group_id = azurerm_proximity_placement_group.sdkperf_az_ppgrp.id

  size                   = var.publisher_node_vm_size
  admin_username         = var.az_admin_username
  network_interface_ids  = [azurerm_network_interface.publisher-nodes-nic[count.index].id]
  zone                   = var.zone

  source_image_reference {
    publisher = "OpenLogic"
    offer     = "Centos"
    sku       = var.source_image_reference_openlogic_centos_sku
    version   = "latest"
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "${var.tag_name_prefix}-publisher-node-${count.index}-OsDisk"
  }
  admin_ssh_key {
    username   = var.az_admin_username
    public_key = file(var.public_key_path)
  }
  tags = {
    Name    = "${var.tag_name_prefix}-publisher-node-${count.index}"
    Owner   = var.tag_owner
    Purpose = "sdkperf benchmarking - publisher node"
    Days    = var.tag_days
  }

# Do not flag the azurerm_linux_virtual_machine resource as completed, until the VM is able to accept SSH connections, otherwise the Ansible call will fail
  provisioner "remote-exec" {
    inline = [
      "echo 'Publisher Node: SSH ready to rock'",
      "echo 'remote-exec: ${self.public_ip_address}, ${var.az_admin_username}, ${var.private_key_path}'"
    ]
    connection {
      agent       = false
      host        = self.public_ip_address
      type        = "ssh"
      user        = var.az_admin_username
      private_key = file(var.private_key_path)
    }
  }
}

resource "azurerm_network_interface" "publisher-nodes-nic" {
  count = "1"

  name                   = "${var.tag_name_prefix}-publisher-nic-${count.index}"
  location               = var.az_resgrp_name == "" ? azurerm_resource_group.sdkperf_az_resgrp[0].location : data.azurerm_resource_group.input_resgroup[0].location
  resource_group_name    = var.az_resgrp_name == "" ? azurerm_resource_group.sdkperf_az_resgrp[0].name : var.az_resgrp_name
  enable_accelerated_networking = true
  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id == "" ? azurerm_subnet.sdkperf_subnet[0].id : var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publisher-nodes-pubip[count.index].id
  }
  tags = {
    Name    = "${var.tag_name_prefix}-publisher-nic-${count.index}"
    Owner   = var.tag_owner
    Purpose = "sdkperf benchmarking - publisher node nic"
    Days    = var.tag_days
  }
}

resource "azurerm_public_ip" "publisher-nodes-pubip" {
  count = "1"

  name                   = "${var.tag_name_prefix}-publisher-pubip-${count.index}"
  location               = var.az_resgrp_name == "" ? azurerm_resource_group.sdkperf_az_resgrp[0].location : data.azurerm_resource_group.input_resgroup[0].location
  resource_group_name    = var.az_resgrp_name == "" ? azurerm_resource_group.sdkperf_az_resgrp[0].name : var.az_resgrp_name
  allocation_method      = "Static"
  sku                    = "Standard"
  zones                   = [var.zone]
  tags = {
    Name    = "${var.tag_name_prefix}-publisher-pubip-${count.index}"
    Owner   = var.tag_owner
    Purpose = "sdkperf benchmarking - publisher node pubip"
    Days    = var.tag_days
  }
}
#Asociate the VM NIC to the Sec Group created
resource "azurerm_network_interface_security_group_association" "publisher-nodes-secgrp_association" {
  count = "1"
  network_interface_id      = azurerm_network_interface.publisher-nodes-nic[count.index].id
  network_security_group_id = azurerm_network_security_group.sdkperf_secgrp.id
}
#
# END: publisher node
################################################################

################################################################
# BEGIN: consumer nodes
#
resource "azurerm_linux_virtual_machine" "consumer-nodes" {

  count = var.consumer_node_vm_count

  name                   = "${var.tag_name_prefix}-consumer-node-${count.index}"
  #If a Resource Group was specified we'll query its Location use it, otherwise use the location of the Res Group that was just created
  location               = var.az_resgrp_name == "" ? azurerm_resource_group.sdkperf_az_resgrp[0].location : data.azurerm_resource_group.input_resgroup[0].location
  resource_group_name    = var.az_resgrp_name == "" ? azurerm_resource_group.sdkperf_az_resgrp[0].name : var.az_resgrp_name

  proximity_placement_group_id = azurerm_proximity_placement_group.sdkperf_az_ppgrp.id

  size                   = var.consumer_node_vm_size
  admin_username         = var.az_admin_username
  network_interface_ids  = [azurerm_network_interface.consumer-nodes-nic[count.index].id]
  zone                   = var.zone

  source_image_reference {
    publisher = "OpenLogic"
    offer     = "Centos"
    sku       = var.source_image_reference_openlogic_centos_sku
    version   = "latest"
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "${var.tag_name_prefix}-consumer-node-${count.index}-OsDisk"
  }
  admin_ssh_key {
    username   = var.az_admin_username
    public_key = file(var.public_key_path)
  }
  tags = {
    Name    = "${var.tag_name_prefix}-consumer-node-${count.index}"
    Owner   = var.tag_owner
    Purpose = "sdkperf benchmarking - consumer node"
    Days    = var.tag_days
    consumer_node_number = "${count.index}"
  }

# Do not flag the azurerm_linux_virtual_machine resource as completed, until the VM is able to accept SSH connections, otherwise the Ansible call will fail
  provisioner "remote-exec" {
    inline = [
      "echo 'Consumer Node: SSH ready to rock'",
      "echo 'remote-exec: ${self.public_ip_address}, ${var.az_admin_username}, ${var.private_key_path}'"
    ]
    connection {
      agent       = false
      host        = self.public_ip_address
      type        = "ssh"
      user        = var.az_admin_username
      private_key = file(var.private_key_path)
    }
  }
}

resource "azurerm_network_interface" "consumer-nodes-nic" {

  count = var.consumer_node_vm_count

  name                   = "${var.tag_name_prefix}-consumer-nic-${count.index}"
  location               = var.az_resgrp_name == "" ? azurerm_resource_group.sdkperf_az_resgrp[0].location : data.azurerm_resource_group.input_resgroup[0].location
  resource_group_name    = var.az_resgrp_name == "" ? azurerm_resource_group.sdkperf_az_resgrp[0].name : var.az_resgrp_name
  enable_accelerated_networking = true
  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id == "" ? azurerm_subnet.sdkperf_subnet[0].id : var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.consumer-nodes-pubip[count.index].id
  }
  tags = {
    Name    = "${var.tag_name_prefix}-consumer-nic-${count.index}"
    Owner   = var.tag_owner
    Purpose = "sdkperf benchmarking - consumer node nic"
    Days    = var.tag_days
  }
}

resource "azurerm_public_ip" "consumer-nodes-pubip" {

  count = var.consumer_node_vm_count

  name                   = "${var.tag_name_prefix}-consumer-pubip-${count.index}"
  location               = var.az_resgrp_name == "" ? azurerm_resource_group.sdkperf_az_resgrp[0].location : data.azurerm_resource_group.input_resgroup[0].location
  resource_group_name    = var.az_resgrp_name == "" ? azurerm_resource_group.sdkperf_az_resgrp[0].name : var.az_resgrp_name
  allocation_method      = "Static"
  sku                    = "Standard"
  zones                   = [var.zone]
  tags = {
    Name    = "${var.tag_name_prefix}-consumer-pubip-${count.index}"
    Owner   = var.tag_owner
    Purpose = "sdkperf benchmarking - consumer node pubip"
    Days    = var.tag_days
  }
}
#Asociate the VM NIC to the Sec Group created
resource "azurerm_network_interface_security_group_association" "consumer-nodes-secgrp_association" {
  count = var.consumer_node_vm_count
  network_interface_id      = azurerm_network_interface.consumer-nodes-nic[count.index].id
  network_security_group_id = azurerm_network_security_group.sdkperf_secgrp.id
}
#
# END: consumer nodes
################################################################

resource "local_file" "sdkperf_nodes_file" {
  content = templatefile("../templates/shared-setup/az.sdkperf-nodes.tpl",
    {
      latency_nodes = azurerm_linux_virtual_machine.latency-nodes.*
      publisher_nodes = azurerm_linux_virtual_machine.publisher-nodes.*
      consumer_nodes = azurerm_linux_virtual_machine.consumer-nodes.*
    }
  )
  filename = "../../../shared-setup/azure.${var.tag_name_prefix}-standalone.sdkperf-nodes.json"
}

###
# The End.
