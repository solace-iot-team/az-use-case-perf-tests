# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# ---------------------------------------------------------------------------------------------

resource "local_file" "inventory_file" {
  content = templatefile("../templates/shared-setup/az.inventory.tpl",
    {
      sdk_perf_nodes = azurerm_linux_virtual_machine.sdkperf-nodes.*
      solace_broker_nodes = azurerm_linux_virtual_machine.solace-broker-nodes.*
      cloud_provider = var.cloud_provider
      tag_name_prefix = var.tag_name_prefix
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
    node_ids = "${join(",", azurerm_linux_virtual_machine.solace-broker-nodes.*.id, azurerm_linux_virtual_machine.sdkperf-nodes.*.id)}"
  }
  provisioner "local-exec" {
    # requires env var set: export ANSIBLE_PYTHON_INTERPRETER={path-to-python-3}
    command = "../bootstrap/_run.bootstrap.sh azure.${var.tag_name_prefix}-standalone"
    # command = "echo 'now bootstrap ...'"
  }
  depends_on = [
      local_file.inventory_file
    ]
}


###
# The End.
