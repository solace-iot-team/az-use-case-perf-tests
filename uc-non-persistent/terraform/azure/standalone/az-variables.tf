####################################################################################################
# INSTRUCTIONS:
# (1) Customize these variables to your perference
# (2) Make sure the account you're running terraform with has proper permissions in your Azure env
####################################################################################################

# Azure config
variable "az_region" {
  #  default = "West US" # No AZ Supports, Supports UltraD not in AZ - Total Regional vCPUs 100
  # default = "West US 2" # Supports AZ, Supports UltraD in 3 AZ    - Total Regional vCPUs 10
  #  default = "Japan East" # Supports AZ, Supports UltraD in 2 AZ   - Total Regional vCPUs 160
  default = "West Europe"
}

# sdkperf nodes count
variable "sdkperf_nodes_count" {
    default = "4"
    type        = string
    description = "The number of sdkperf nodes to be created."
}

# solace broker nodes count
variable "solace_broker_count" {
    default = "1"
    type        = string
    description = "The number of Solace Broker nodes to be created."
}

# General Variables
variable "tag_owner" {
  default = "RJGU"
}
variable "tag_days" {
  default = "1"
}
variable "tag_name_prefix" {
  default = "rjguzz"
}

variable "az_resgrp_name" {
  default = ""
  #default = "subnet-0db7d4f1da1d01bd8"
  type        = string
  description = "The Azure Resource Group Name to be used for containing the resources - Leave the value empty for automatically creating one."
}


variable "subnet_id" {
  default = ""
  #default = "subnet-0db7d4f1da1d01bd8"
  type        = string
  description = "The Azure subnet_id to be used for creating the nodes - Leave the value empty for automatically creating one."
}
variable "sdkperf_secgroup_ids" {
  default = [""]
  #default = ["sg-08a5f21a2e6ebf19e"]
  description = "The Azure security_group_ids to be asigned to the sdkperf nodes - Leave the value empty for automatically creating one."
}
variable "solacebroker_secgroup_ids" {
  default = [""]
  #default = ["sg-08a5f21a2e6ebf19e"]
  description = "The Azure security_group_ids to be asigned to the Solace broker nodes - Leave the value empty for automatically creating one."
}


# ssh config
variable "az_admin_username" {
  default = "centos"
  type        = string
  description = "The admin username to be used for accesing this Azure VM"
}
# If no  Private and Public Keys exist, they can be created with the "ssh-keygen -f ../aws_key" command
variable "public_key_path" {
  default = "../../../keys/azure_key.pub"
  description = "Local path to the public key to be used on the Azure VMs"
}
variable "private_key_path" {
  default = "../../../keys/azure_key"
  description = "Local path to the private key used to connect to the Instances (Not to be uploaded to AWS)"
}

# Solace Broker External Storage Variables
variable "solacebroker_storage_device_name" {
  default = "/dev/sdc"
  description = "device name to assign to the storage device"
}
variable "solacebroker_storage_size" {
#  default         = "128"  # (  500 IOPs 	100 MB/second Throughput)
#  default         = "256"  # (1,100 IOPs 	125 MB/second Throughput)
  default         = "512"  # (2,300 IOPs 	150 MB/second Throughput)
#  default         = "1024" # (5,000 IOPs 	200 MB/second Throughput)

  description = "Size of the Storage Device in GB"
}
variable "solacebroker_storage_iops" {
  default = "3000"
  description = "Number of IOPs to allocate to the Storage device - must be a MAX ratio or 1:50 of the Storage Size"
}
