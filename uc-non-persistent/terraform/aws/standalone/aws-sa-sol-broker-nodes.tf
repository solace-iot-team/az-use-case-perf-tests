####################################################################################################
# INSTRUCTIONS:
# (1) Customize these instance values to your preference.
#       * instance_type
#       * availability_zone
#       * tags
# (2) On the Ansible Playbooks & Var files - Adjust the PubSub+ SW Broker:
#         - Scaling tier
#         - external storage device name - ex: /dev/sdc or /dev/xvdc
#         - Docker Version
#         - Solace Image Type, Standard, Enterprise or Enterprise Eval
#     according to the VM size/type
# (3) Make sure the account you're running terraform with has proper permissions in your AWS env
####################################################################################################

resource "aws_instance" "solace-broker-nodes" {
  count = var.solace_broker_count

  placement_group        = aws_placement_group.sdkperf_placement_grp.id #placement group defined in aws-sa-sdkperf-nodes.tf
  ami                    = var.centOS_ami[var.aws_region]
  # key_name               = var.aws_ssh_key_name
  key_name               = "${var.tag_name_prefix}_${var.aws_ssh_key_name}"
  subnet_id              = var.subnet_id == "" ? aws_subnet.sdkperf_subnet[0].id : var.subnet_id
  vpc_security_group_ids = var.solacebroker_secgroup_ids == [""] ? ["${aws_security_group.solacebroker_secgroup[0].id}"] : var.solacebroker_secgroup_ids

  instance_type          = var.sol_messaging_vm_type
  # with placement_group VMs should end in same availablity zone anyways
  #availability_zone      = "${var.aws_region}a"

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 8
    delete_on_termination = true
  }

  ebs_block_device {
    device_name = var.solacebroker_storage_device_name
    volume_size = var.solacebroker_storage_size
    delete_on_termination = true

    volume_type = "gp2"
#    volume_type = "io1"
#    iops = var.solacebroker_storage_iops
  }

  tags = {
    Name    = "${var.tag_name_prefix}-solacebroker-node-${count.index}"
    Owner   = var.tag_owner
    Purpose = "sdkperf benchmarking - Broker node"
    Days    = var.tag_days
  }

 # Do not flag the aws_instance resource as completed, until the VM is able to accept SSH connections, otherwise the Ansible call will fail
  provisioner "remote-exec" {
    inline = ["echo 'SSH ready to rock'"]

    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = var.ssh_user
      private_key = file(var.private_key_path)
    }
  }
}

  resource "local_file" "broker_nodes_file" {
  content = templatefile("../../templates/shared-setup/aws.broker-nodes.tpl",
    {
      nodes = aws_instance.solace-broker-nodes.*
    }
  )
  filename = "../../../shared-setup/aws.${var.tag_name_prefix}-standalone.broker-nodes.json"
  }

###
# The End.
