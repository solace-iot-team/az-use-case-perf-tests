# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# ---------------------------------------------------------------------------------------------

resource "local_file" "inventory_file" {
  content = templatefile("../templates/shared-setup/az.inventory.tpl",
    {
      cloud_provider = var.cloud_provider
      tag_name_prefix = var.tag_name_prefix

      latency_node = azurerm_linux_virtual_machine.latency-nodes[0]
      publisher_nodes = azurerm_linux_virtual_machine.publisher-nodes.*
      consumer_nodes = azurerm_linux_virtual_machine.consumer-nodes.*
      broker_node = azurerm_linux_virtual_machine.solace-broker-nodes[0]
    }
  )
  filename = "../../../shared-setup/azure.${var.tag_name_prefix}-standalone.inventory.json"
  depends_on = [
        local_file.sdkperf_nodes_file,
        local_file.broker_nodes_file,
        azurerm_virtual_machine_data_disk_attachment.solace-broker-datadisk-attach, # Disk allocation to an Azure VM happens after the VM creation, therefore we have to explicitly wait
    ]
}

resource "null_resource" "trigger_bootstrap" {
  triggers = {
    always_run      = "${timestamp()}"
    tag_name_prefix = "${var.tag_name_prefix}"
  }
  provisioner "local-exec" {
    # requires env var set: export ANSIBLE_PYTHON_INTERPRETER={path-to-python-3}
    command = <<EOT
      export APPLY_KERNEL_OPTIMIZATIONS=${var.apply_kernel_optimizations}
      export APPLY_MELLANOX_VMA=${var.apply_mellanox_vma}
      ../bootstrap/_run.bootstrap.sh azure.${var.tag_name_prefix}-standalone
EOT
  }
  provisioner "local-exec" {
    when    = destroy
    # requires env var set: export ANSIBLE_PYTHON_INTERPRETER={path-to-python-3}
    command = "../bootstrap/_run.bootstrap.destroy.sh azure.${self.triggers.tag_name_prefix}-standalone"
  }
  depends_on = [
      local_file.inventory_file
    ]
}

###
# The End.
