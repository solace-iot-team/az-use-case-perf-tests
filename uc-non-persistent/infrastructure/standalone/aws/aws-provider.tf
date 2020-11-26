# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# Copyright (c) 2020, Solace Corporation, Jochen Traunecker (jochen.traunecker@solace.com)
# ---------------------------------------------------------------------------------------------

provider "aws" {
  region  = var.aws_region
  version = "~> 2.0"
}

resource "local_file" "env_file" {
  content = templatefile(
    "../templates/shared-setup/aws.env.tpl",
    {
      ppg_id = aws_placement_group.sdkperf_placement_grp.id
      ppg = "none"
      zone = var.zone
      region = var.aws_region
      apply_kernel_optimizations = var.apply_kernel_optimizations
      apply_mellanox_vma = var.apply_mellanox_vma
    }
  )
  filename = "../../../shared-setup/aws.${var.tag_name_prefix}-standalone.env.json"
}

###
# The End.
