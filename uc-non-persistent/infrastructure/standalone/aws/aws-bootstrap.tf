# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# ---------------------------------------------------------------------------------------------

resource "local_file" "inventory_file" {
  content = templatefile("../templates/shared-setup/aws.inventory.tpl",
    {
      admin_username = var.ssh_user
      cloud_provider = var.cloud_provider
      tag_name_prefix = var.tag_name_prefix

      latency_node = aws_instance.latency-nodes[0]
      publisher_nodes = aws_instance.publisher-nodes.*
      consumer_nodes = aws_instance.consumer-nodes.*
      broker_node = aws_instance.solace-broker-nodes[0]
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
    always_run = "${timestamp()}"
    tag_name_prefix = "${var.tag_name_prefix}"
  }
  provisioner "local-exec" {
    # requires env var set: export ANSIBLE_PYTHON_INTERPRETER={path-to-python-3}
    command = <<EOT
      export APPLY_KERNEL_OPTIMIZATIONS=${var.apply_kernel_optimizations}
      export APPLY_MELLANOX_VMA=${var.apply_mellanox_vma}
      ../bootstrap/_run.bootstrap.sh aws.${var.tag_name_prefix}-standalone
EOT
  }
  provisioner "local-exec" {
    when    = destroy
    # requires env var set: export ANSIBLE_PYTHON_INTERPRETER={path-to-python-3}
    command = "../bootstrap/_run.bootstrap.destroy.sh aws.${self.triggers.tag_name_prefix}-standalone"
  }
  depends_on = [
      local_file.inventory_file
    ]
}


###
# The End.
