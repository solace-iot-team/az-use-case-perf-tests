# Azure Infrastructure: Standalone
Creates Azure resources for a standalone Solace broker deployment using terraform.

### Azure Credentials

````bash
az login

export ARM_SUBSCRIPTION_ID={subscription-id}
export ARM_TENANT_ID={tenant-id}
````
## Deployment Settings

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

#### Generate keys

* Name: `azure_key`
* [For details see here](../../../keys)

#### Init terraform
````bash
terraform init
````

## Deploy
````bash
# check what if
terraform plan

# create the resources
terraform apply
````

## Check Shared Setup

````bash
ls ../../../shared-setup/azure.*.broker-nodes.json
ls ../../../shared-setup/azure.*.sdkperf-nodes.json
ls ../../../shared-setup/azure.*.env.json
ls ../../../shared-setup/azure.*.inventory.json
````

## Destroy
````bash
terraform destroy
````

---
The End.
