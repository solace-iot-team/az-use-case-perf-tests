####################################################################################################
# INSTRUCTIONS:
# (1) Customize these instance values to your preference.
#       * instance_type
#       * availability_zone
#       * tags
# (2) Make sure the account you're running terraform with has proper permissions in your Azure env
####################################################################################################

resource "azurerm_linux_virtual_machine" "sdkperf-nodes" {

  count = var.sdkperf_nodes_count

  name                   = "${var.tag_name_prefix}-sdkperf-node-${count.index}"
  #If a Resource Group was specified we'll query its Location use it, otherwise use the location of the Res Group that was just created
  location               = var.az_resgrp_name == "" ? azurerm_resource_group.sdkperf_az_resgrp[0].location : data.azurerm_resource_group.input_resgroup[0].location
  resource_group_name    = var.az_resgrp_name == "" ? azurerm_resource_group.sdkperf_az_resgrp[0].name : var.az_resgrp_name

  proximity_placement_group_id = azurerm_proximity_placement_group.sdkperf_az_ppgrp.id
  
  size                   = var.sdk_perf_nodes_vm_size
  admin_username         = var.az_admin_username
  network_interface_ids  = [azurerm_network_interface.sdkperf-nodes-nic[count.index].id]
#  zone                   = 1

  source_image_reference {
    publisher = "OpenLogic"
    offer     = "Centos"
    sku       = "7.7"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "${var.tag_name_prefix}-sdkperf-node-${count.index}-OsDisk"
  }

  admin_ssh_key {
    username   = var.az_admin_username
    public_key = file(var.public_key_path)
  }

  tags = {
    Name    = "${var.tag_name_prefix}-sdkperf-node-${count.index}"
    Owner   = var.tag_owner
    Purpose = "sdkperf benchmarking - sdkperf node"
    Days    = var.tag_days
  }

# Do not flag the azurerm_linux_virtual_machine resource as completed, until the VM is able to accept SSH connections, otherwise the Ansible call will fail
  provisioner "remote-exec" {
    inline = [
      "echo 'SDK_PERF: SSH ready to rock'",
      "echo 'remote-exec: ${self.public_ip_address}, ${var.az_admin_username}, ${var.private_key_path}'"
    ]

    connection {
      agent       = false
      host        = self.public_ip_address
      type        = "ssh"
      user        = var.az_admin_username
      # private_key = file("../../../keys/azure_key")
      private_key = file(var.private_key_path)
    }
  }
}

resource "azurerm_network_interface" "sdkperf-nodes-nic" {
  count = var.sdkperf_nodes_count

  name                = "${var.tag_name_prefix}-sdkperf-nic-${count.index}"
  location               = var.az_resgrp_name == "" ? azurerm_resource_group.sdkperf_az_resgrp[0].location : data.azurerm_resource_group.input_resgroup[0].location
  resource_group_name    = var.az_resgrp_name == "" ? azurerm_resource_group.sdkperf_az_resgrp[0].name : var.az_resgrp_name
  
  #accelerated networking not available for all VMs
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id == "" ? azurerm_subnet.sdkperf_subnet[0].id : var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.sdkperf-nodes-pubip[count.index].id
  }

  tags = {
    Name    = "${var.tag_name_prefix}-sdkperf-nic-${count.index}"
    Owner   = var.tag_owner
    Purpose = "sdkperf benchmarking - sdkperf node nic"
    Days    = var.tag_days
  }
}

resource "azurerm_public_ip" "sdkperf-nodes-pubip" {
  count = var.sdkperf_nodes_count

  name                = "${var.tag_name_prefix}-sdkperf-pubip-${count.index}"
  location               = var.az_resgrp_name == "" ? azurerm_resource_group.sdkperf_az_resgrp[0].location : data.azurerm_resource_group.input_resgroup[0].location
  resource_group_name    = var.az_resgrp_name == "" ? azurerm_resource_group.sdkperf_az_resgrp[0].name : var.az_resgrp_name
  allocation_method      = "Dynamic"

  tags = {
    Name    = "${var.tag_name_prefix}-sdkperf-pubip-${count.index}"
    Owner   = var.tag_owner
    Purpose = "sdkperf benchmarking - sdkperf node pubip"
    Days    = var.tag_days
  }
}

#Asociate the VM NIC to the Sec Group created
resource "azurerm_network_interface_security_group_association" "sdkperf-nodes-secgrp_association" {
  count = var.sdkperf_nodes_count

  network_interface_id      = azurerm_network_interface.sdkperf-nodes-nic[count.index].id
  network_security_group_id = azurerm_network_security_group.sdkperf_secgrp.id
}



resource "local_file" "sdkperf_nodes_file" {
  content = templatefile("../../templates/shared-setup/az.sdkperf-nodes.tpl",
    {
      nodes = azurerm_linux_virtual_machine.sdkperf-nodes.*
      #
      # node-names = azurerm_linux_virtual_machine.sdkperf-nodes.*.name
      # node-public-ips = azurerm_linux_virtual_machine.sdkperf-nodes.*.public_ip_address
      # node-private-ips = azurerm_linux_virtual_machine.sdkperf-nodes.*.private_ip_address
    }
  )
  filename = "../../../shared-setup/az.sdkperf-nodes.json"
}

###
# The End.
