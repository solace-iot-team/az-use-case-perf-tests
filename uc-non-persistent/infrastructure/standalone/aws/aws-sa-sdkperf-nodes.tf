####################################################################################################
# INSTRUCTIONS:
# (1) Customize these instance values to your preference.
#       * instance_type
#       * availability_zone
#       * tags
# (2) Make sure the account you're running terraform with has proper permissions in your AWS env
####################################################################################################
resource "aws_placement_group" "sdkperf_placement_grp" {
  name = "${var.tag_name_prefix}-placement-grp"
  strategy = "cluster"
   tags = {
    Name    = "${var.tag_name_prefix}-sdkperf-vpc"
    Owner   = var.tag_owner
    Purpose = "sdkperf benchmarking"
    Days    = var.tag_days
  }
}

resource "aws_instance" "sdkperf-nodes" {

  count = var.sdkperf_nodes_count

  placement_group        = aws_placement_group.sdkperf_placement_grp.id
  ami                    = var.centOS_ami[var.aws_region]
  # key_name               = var.aws_ssh_key_name
  key_name               = "${var.tag_name_prefix}_${var.aws_ssh_key_name}"
  subnet_id              = var.subnet_id == "" ? aws_subnet.sdkperf_subnet[0].id : var.subnet_id
  vpc_security_group_ids = var.sdkperf_secgroup_ids == [""] ? ["${aws_security_group.sdkperf_secgroup[0].id}"] : var.sdkperf_secgroup_ids

  instance_type          = var.sdkperf_vm_type
  # with placement_group VMs should end in same availablity zone anyways
  # availability_zone      = "${var.aws_region}a"

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 8
    delete_on_termination = true
  }
  tags = {
    Name    = "${var.tag_name_prefix}-sdkperf-node-${count.index}"
    Owner   = var.tag_owner
    Purpose = "sdkperf benchmarking - sdkperf node"
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

 resource "local_file" "sdkperf_nodes_file" {
  content = templatefile("../../templates/shared-setup/aws.sdkperf-nodes.tpl",
    {
      nodes = aws_instance.sdkperf-nodes.*
    }
  )
  filename = "../../../shared-setup/aws.${var.tag_name_prefix}-standalone.sdkperf-nodes.json"
 }
