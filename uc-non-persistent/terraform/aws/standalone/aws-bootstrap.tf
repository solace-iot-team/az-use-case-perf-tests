# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# ---------------------------------------------------------------------------------------------

resource "local_file" "inventory_file" {
  content = templatefile("../../templates/shared-setup/aws.inventory.tpl",
    {
      admin_username = var.ssh_user
      sdk_perf_nodes = aws_instance.sdkperf-nodes.*
      solace_broker_nodes = aws_instance.solace-broker-nodes.*
      cloud_provider = var.cloud_provider
      tag_name_prefix = var.tag_name_prefix
    }
  )
  filename = "../../../shared-setup/aws.${var.tag_name_prefix}-standalone.inventory.json"
  depends_on = [
        local_file.sdkperf_nodes_file,
        local_file.broker_nodes_file
    ]
}

resource "null_resource" "trigger_bootstrap" {
  triggers = {
    node_ids = "${join(",", aws_instance.solace-broker-nodes.*.id, aws_instance.sdkperf-nodes.*.id)}"
  }
  provisioner "local-exec" {
    # requires env var set: export ANSIBLE_PYTHON_INTERPRETER={path-to-python-3}
    command = "../../../ansible/bootstrap/run.bootstrap.sh aws.${var.tag_name_prefix}-standalone"
  }
  depends_on = [
      local_file.inventory_file
    ]
}


###
# The End.
