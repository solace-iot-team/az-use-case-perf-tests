####################################################################################################
# INSTRUCTIONS:
# (1) Customize these variables to your perference
# (2) Make sure the account you're running terraform with has proper permissions in your Azure env
####################################################################################################

############################################################################################################
# BEGIN CUSTOMIZATION
#

variable "az_region" {
  type = string
  # default = "West US"
  # default = "West US 2"
  # default = "Japan East"
  default = "West Europe"
}
variable "zone" {
  type = string
  description = "availability zone. should match the controller zone."
  default = "1"
}
variable "tag_name_prefix" {
  type = string
  description = "unique prefix applied to all resources"
}
variable "tag_owner" {
  type = string
  description = "owner used for tagging"
}
variable "solace_broker_node_vm_size" {
  type = string
  description = "the VM size for the solace broker node"
  default = "Standard_F16s_v2"
  # default = "Standard_F32s_v2"     # (32 Cores, 64GB RAM, 64000 max IOPS)
  # default = "Standard_F16s_v2"     # (16 Cores, 32GB RAM, 25600 max IOPS)
  # default = "Standard_D8s_v3"      # (8 Cores, 32GB RAM, 12800 max IOPS)
}
variable "latency_node_vm_size" {
  type = string
  default = "Standard_F4s_v2"
}
variable "publisher_node_vm_size" {
  type = string
  default = "Standard_F4s_v2"
}
variable "consumer_node_vm_size" {
  type = string
  default = "Standard_F4s_v2"
}
variable "consumer_node_vm_count" {
  type = string
  default = "2"
}
variable "apply_kernel_optimizations" {
  type = bool
  default = false
}
variable "apply_mellanox_vma" {
  type = bool
  default = false
}
variable "source_image_reference_openlogic_centos_sku" {
  type = string
  default = "7.7"
  validation {
    # condition     = var.source_image_reference_openlogic_centos_sku == "7.7" || var.source_image_reference_openlogic_centos_sku == "8_2" || var.source_image_reference_openlogic_centos_sku == "8_2-gen2"
    # error_message = "Invalid value provided for variable source_image_reference_openlogic_centos_sku. Allowed values: ['7.7', '8_2', '8_2-gen2']."
    condition     = var.source_image_reference_openlogic_centos_sku == "7.7" || var.source_image_reference_openlogic_centos_sku == "8_2"
    error_message = "Invalid value provided for variable source_image_reference_openlogic_centos_sku. Allowed values: ['7.7', '8_2']."
  }
}


#
# END CUSTOMIZATION
############################################################################################################


############################################################################################################
#
# DO NOT CHANGE ANY VARIABLES FROM HERE ONWARDS
#
############################################################################################################

variable "cloud_provider" {
  default = "azure"
}
variable "tag_days" {
  default = "1"
}
variable "solace_broker_vm_count" {
    default = "1"
    type        = string
    description = "The number of Solace Broker nodes to be created."
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
