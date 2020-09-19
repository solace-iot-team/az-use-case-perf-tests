# Terraform: Azure: Standalone

- creates azure resources for the use case.
- generates output in {root}/shared-setup

## Change Directory
````bash
# execute all commands in this directory
cd {root}/uc-non-persistent/terraform/azure/standalone
````

## Pre-Requisites

### Terraform

Install Terraform.

### Azure Login

````bash
az login

export ARM_SUBSCRIPTION_ID={subscription-id}
export ARM_TENANT_ID={tenant-id}
````

## Settings

Customizing the deployment to Azure:

````bash

cp az-variables.template az-variables.tf

vi az-variables.tf

    # the azure region
    variable "az_region" {
      default = "{azure-region}"
    }
    # prefix for all resources
    variable "tag_name_prefix" {
      default = "{prefix}"
    }
    # the tag for all resources
    variable "tag_owner" {
      default = "{owner}"
    }
    # the VM size for the solace broker
    variable "solace_broker_node_vm_size" {
      default = "{vm-size}"
    }
    # the VM size for the sdk perf nodes
    variable "sdk_perf_nodes_vm_size" {
      default = "{vm-size}"
    }

````

## Prepare

**[See here for generating the keys](../../../keys).**

````bash
# to enable terraform logging
export TF_LOG_PATH=./tf_log.log
export TF_LOG=TRACE # TRACE, DEBUG, INFO, WARN or ERROR
````

````bash
# initialize terraform
terraform init
````
## Run

````bash
# check what if
terraform plan

# create the resources
terraform apply
````

#### Check Output of Run

````bash
cd {root}/shared-setup
  less broker-nodes.json
  less sdkperf-nodes.json
````

#### Login to the VMs

````bash
# find the public ip address of the vms:
less {root}/shared-setup/broker-nodes.json
less {root}/shared-setup/sdkperf-nodes.json
# ssh ...
ssh -i ../../../keys/azure_key centos@{public-ip-address}
````

### Destroy Resources

````bash
# destroy the resources
terraform destroy
````

---
The End.
