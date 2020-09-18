# Terraform: Azure: Standalone

- creates azure resources for the use case.
- generates output in {root}/shared-setup

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

vi az-variables.tf

    # change the prefix for all the resources
    variable "tag_name_prefix" {
      default = "my-prefix"
    }

    # change the number of sdk perf nodes
    variable "sdkperf_nodes_count" {
        default = "4"
        type        = string
        description = "The number of sdkperf nodes to be created."
    }
````

````bash
vi az-sa-sol-broker-nodes.tf
    # change the size of the vm
    size = "Standard_F16s_v2"     # (16 Cores, 32GB RAM, 25600 IOPS)
````

````bash
vi az-sa-sdkperf-nodes.tf
    # change the size of the vm
    size = "Standard_F4s_v2" # (4 CPUs, 8 GB RAM, max IOPS: 6400)
````

## Prepare

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

### Destroy Resources

````bash
# destroy the resources
terraform destroy
````

---
The End.
