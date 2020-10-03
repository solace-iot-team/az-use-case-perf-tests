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

### AWS credentials

````bash
export AWS_ACCESS_KEY_ID={aws-access-key}
export AWS_SECRET_ACCESS_KEY={aws-secret-access-key}
export AWS_DEFAULT_REGION={aws-default-region} 
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

##### Azure
Login into the Azure Portal and check the new resource group: _**{prefix}-sdkperf_resgrp**_.

Check the generated output:
````bash
cd {root}/shared-setup
  less az.broker-nodes.json
  less az.sdkperf-nodes.json
````

##### AWS
Login into the AWS Console and check the new resource group: _**{prefix}-sdkperf_resgrp**_.

Check the generated output:
````bash
cd {root}/shared-setup
  less aws.broker-nodes.json
  less

#### Login to the VMs

##### Azure
````bash
# find the public ip address of the Azure vms:
less {root}/shared-setup/az.broker-nodes.json
less {root}/shared-setup/az.sdkperf-nodes.json
# ssh ...
ssh -i ../../../keys/az_key centos@{public-ip-address}
````

##### AWS
````bash
# find the public ip address of the Azure vms:
less {root}/shared-setup/aws.broker-nodes.json
less {root}/shared-setup/aws.sdkperf-nodes.json
# ssh ...
ssh -i ../../../keys/aws_key centos@{public-ip-address}
````

### Destroy Resources

````bash
# destroy the resources
terraform destroy
````

---
The End.
