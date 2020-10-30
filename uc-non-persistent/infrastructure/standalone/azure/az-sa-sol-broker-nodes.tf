# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# Copyright (c) 2020, Solace Corporation, Jochen Traunecker (jochen.traunecker@solace.com)
# ---------------------------------------------------------------------------------------------

resource "azurerm_linux_virtual_machine" "solace-broker-nodes" {

  count = var.solace_broker_count

  name                   = "${var.tag_name_prefix}-solacebroker-node-${count.index}"
  #If a Resource Group was specified we'll query its Location and use it, otherwise use the location of the Res Group that was just created
  location               = var.az_resgrp_name == "" ? azurerm_resource_group.sdkperf_az_resgrp[0].location : data.azurerm_resource_group.input_resgroup[0].location
  resource_group_name    = var.az_resgrp_name == "" ? azurerm_resource_group.sdkperf_az_resgrp[0].name : var.az_resgrp_name

  #share same proximity placement group with SolaceBroker and SDKPerf nodes
  proximity_placement_group_id = azurerm_proximity_placement_group.sdkperf_az_ppgrp.id
  zone                   = var.zone
  admin_username         = var.az_admin_username
  network_interface_ids  = [azurerm_network_interface.solacebroker-nodes-nic[count.index].id]
  size                   = var.solace_broker_node_vm_size

#NOTE: "ultra_ssd_enabled" HAS to be set when using UltraSSD_LRS data disks
  additional_capabilities {
#    ultra_ssd_enabled      = true
    ultra_ssd_enabled     = false
  }

  source_image_reference {
    publisher = "OpenLogic"
    offer     = "Centos"
    sku       = "7.7"
    version   = "latest"
  }

  os_disk {
    name                 = "${var.tag_name_prefix}-solacebroker-node-${count.index}-OsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  admin_ssh_key {
    username   = var.az_admin_username
    public_key = file(var.public_key_path)
  }

  tags = {
    Name    = "${var.tag_name_prefix}-solacebroker-node-${count.index}"
    Owner   = var.tag_owner
    Purpose = "sdkperf benchmarking - Broker node"
    Days    = var.tag_days
  }

# Do not flag the azurerm_linux_virtual_machine resource as completed, until the VM is able to accept SSH connections, otherwise the Ansible call will fail
  provisioner "remote-exec" {
    inline = [
      "echo 'BROKER SSH ready to rock'",
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

resource "azurerm_managed_disk" "solace-broker-datadisk" {
  count = var.solace_broker_count

  name                 = "${var.tag_name_prefix}-solacebroker-node-${count.index}-datadisk"
  location             = var.az_resgrp_name == "" ? azurerm_resource_group.sdkperf_az_resgrp[0].location : data.azurerm_resource_group.input_resgroup[0].location
  resource_group_name  = var.az_resgrp_name == "" ? azurerm_resource_group.sdkperf_az_resgrp[0].name : var.az_resgrp_name
  create_option        = "Empty"
  disk_size_gb         = var.solacebroker_storage_size

  storage_account_type = "Premium_LRS"
  zones                  = [ var.zone ]

  tags = {
    Name    = "${var.tag_name_prefix}-solacebroker-node-${count.index}-datadisk"
    Owner   = var.tag_owner
    Purpose = "sdkperf benchmarking - Broker node Data Disk"
    Days    = var.tag_days
  }
}

resource "azurerm_virtual_machine_data_disk_attachment" "solace-broker-datadisk-attach" {
  count = var.solace_broker_count

  managed_disk_id    = azurerm_managed_disk.solace-broker-datadisk[count.index].id
  virtual_machine_id = azurerm_linux_virtual_machine.solace-broker-nodes[count.index].id
  lun                = "0"
#NOTE: Set "caching" to None when using UltraSSD_LRS data disks
#  caching            = "ReadWrite"
#  caching            = "ReadOnly"
  caching            = "None"
}

resource "azurerm_network_interface" "solacebroker-nodes-nic" {
  count = var.solace_broker_count

  name                   = "${var.tag_name_prefix}-solacebroker-nic-${count.index}"
  location               = var.az_resgrp_name == "" ? azurerm_resource_group.sdkperf_az_resgrp[0].location : data.azurerm_resource_group.input_resgroup[0].location
  resource_group_name    = var.az_resgrp_name == "" ? azurerm_resource_group.sdkperf_az_resgrp[0].name : var.az_resgrp_name

  #accelerated networking not available for all VMs
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id == "" ? azurerm_subnet.sdkperf_subnet[0].id : var.subnet_id
    # private_ip_address_allocation = "Dynamic" - possible source of error if not assigned in time
    private_ip_address_allocation = "Static"
    public_ip_address_id          = azurerm_public_ip.solacebroker-nodes-pubip[count.index].id
  }

  tags = {
    Name    = "${var.tag_name_prefix}-solacebroker-nic-${count.index}"
    Owner   = var.tag_owner
    Purpose = "sdkperf benchmarking - solace broker node nic"
    Days    = var.tag_days
  }
}

resource "azurerm_public_ip" "solacebroker-nodes-pubip" {
  count = var.solace_broker_count

  name                = "${var.tag_name_prefix}-solacebroker-pubip-${count.index}"
  location               = var.az_resgrp_name == "" ? azurerm_resource_group.sdkperf_az_resgrp[0].location : data.azurerm_resource_group.input_resgroup[0].location
  resource_group_name    = var.az_resgrp_name == "" ? azurerm_resource_group.sdkperf_az_resgrp[0].name : var.az_resgrp_name

  allocation_method      = "Static"
  sku                    = "Standard"
  zones                   = [var.zone]

  tags = {
    Name    = "${var.tag_name_prefix}-solacebroker-pubip-${count.index}"
    Owner   = var.tag_owner
    Purpose = "sdkperf benchmarking - solacebroker node pubip"
    Days    = var.tag_days
  }
}

#Asociate the VM NIC to the Sec Group created
resource "azurerm_network_interface_security_group_association" "solacebroker-nodes-secgrp_association" {
  count = var.solace_broker_count

  network_interface_id      = azurerm_network_interface.solacebroker-nodes-nic[count.index].id
  network_security_group_id = azurerm_network_security_group.solacebroker_secgrp.id
}

resource "local_file" "broker_nodes_file" {
  content = templatefile("../templates/shared-setup/az.broker-nodes.tpl",
    {
      nodes = azurerm_linux_virtual_machine.solace-broker-nodes.*
    }
  )
  filename = "../../../shared-setup/azure.${var.tag_name_prefix}-standalone.broker-nodes.json"
}


###
# The End.
