####################################################################################################
# INSTRUCTIONS:
# (1) Customize these variables to your perference
# (2) Make sure the account you're running terraform with has proper permissions in your AWS env
####################################################################################################

############################################################################################################
# BEGIN CUSTOMIZATION
#

variable "aws_region" {
  type = string
  default = "eu-central-1"
}
variable "tag_name_prefix" {
  type = string
  description = "unique prefix applied to all resources"
}
variable "tag_owner" {
  type = string
  description = "owner used for tagging"
}
variable "solace_broker_vm_type" {
  type = string
  # default = "m5a.4xlarge"    # (16 CPUs  64G RAM - AMD Powered General Purpose)
  default = "m5a.8xlarge"    # (32 CPUs  128G RAM - AMD Powered General Purpose)
  description = "the VM size for the solace broker node"
}
variable "latency_node_vm_type" {
  type = string
  default = "m5a.xlarge" # (4 CPUs, 16 GB RAM)
  # default = "m5a.xlarge"    # (2 CPUs  8G RAM - General Purpose)
}
variable "publisher_node_vm_type" {
  type = string
  default = "m5a.xlarge" # (4 CPUs, 16 GB RAM)
  # default = "m5a.xlarge"    # (2 CPUs  8G RAM - General Purpose)
}
variable "consumer_node_vm_type" {
  type = string
  default = "m5a.xlarge" # (4 CPUs, 16 GB RAM)
  # default = "m5a.xlarge"    # (2 CPUs  8G RAM - General Purpose)
}
variable "consumer_node_vm_count" {
  type = string
  default = "2"
}
variable "apply_kernel_optimizations" {
  type = bool
  default = false
  validation {
    condition     = var.apply_kernel_optimizations == false
    error_message = "Invalid value provided for variable apply_kernel_optimizations. Allowed values: ['false']."
  }
}
variable "apply_mellanox_vma" {
  type = bool
  default = false
  validation {
    condition     = var.apply_mellanox_vma == false
    error_message = "Invalid value provided for variable apply_mellanox_vma. Allowed values: ['false']."
  }
}

#
# END CUSTOMIZATION
############################################################################################################

variable "zone" {
  default = "auto"
}
variable "cloud_provider" {
  default = "aws"
}

variable "tag_days" {
  default = "1"
}

variable "solace_broker_vm_count" {
    default = "1"
    type        = string
    description = "The number of Solace Broker nodes to be created."
}

variable "subnet_id" {
  default = ""
  #default = "subnet-0db7d4f1da1d01bd8"
  type        = string
  description = "The AWS subnet_id to be used for creating the nodes - Leave the value empty for automatically creating one."
}
variable "sdkperf_secgroup_ids" {
  default = [""]
  #default = ["sg-08a5f21a2e6ebf19e"]
  description = "The AWS security_group_ids to be asigned to the sdkperf nodes - Leave the value empty for automatically creating one."
}
variable "solacebroker_secgroup_ids" {
  default = [""]
  #default = ["sg-08a5f21a2e6ebf19e"]
  description = "The AWS security_group_ids to be asigned to the Solace broker nodes - Leave the value empty for automatically creating one."
}


# ssh config
# If the Key Pair is already created on AWS leave an empty public_key_path, otherwise terraform will try to create it and upload the public key
variable "aws_ssh_key_name" {
  default = "iotteam_sdkperf_tfsa_key"
  description = "The Key pair Name to be created on AWS."
}
# If no  Private and Public Keys exist, they can be created with the "ssh-keygen -f ../aws_key" command
variable "public_key_path" {
  default = "../../../keys/aws_key.pub"
  description = "Local path to the public key to be uploaded to AWS"
}
variable "private_key_path" {
  default = "../../../keys/aws_key"
  description = "Local path to the private key used to connect to the Instances (Not to be uploaded to AWS)"
}
variable "ssh_user" {
  default = "centos"
  description = "SSH user to connect to the created instances (defined by the AMI being used)"
}

variable "centOS_ami" {
  type        = map
  default = { # CentOS 7 (x86_64) - with Updates HVM
    eu-central-1 = "ami-095e1a4d3d632d215"
    us-west-1 = "ami-02676464a065c9c05"
    eu-west-1 = "ami-04f5641b0d178a27a"
  }
}

# Solace Broker External Storage Variables
variable "solacebroker_storage_device_name" {
  default = "/dev/sdc"
  description = "device name to assign to the storage device"
}
variable "solacebroker_storage_size" {
  default = 700 # (2100 IOPs on a gp2)
#  default = 1024 # (3072 IOPs on a gp2)
  description = "Size of the Storage Device in GB"
}
variable "solacebroker_storage_iops" {
  default = "3000"
  description = "Number of IOPs to allocate to the Storage device - must be a MAX ratio or 1:50 of the Storage Size"
}
