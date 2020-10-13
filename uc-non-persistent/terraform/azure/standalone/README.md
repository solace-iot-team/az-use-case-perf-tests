# Azure Infrastructure: Standalone

Creates Azure resources for a standalone Solace broker deployment using **Terraform** and **Ansible**.

### Azure Credentials

````bash
az login

export ARM_SUBSCRIPTION_ID={subscription-id}
export ARM_TENANT_ID={tenant-id}
````

### Ansible Python Interpreter

````bash
export ANSIBLE_PYTHON_INTERPRETER={path-to-python-3}
````

## Deployment Settings

````bash

cp az-variables.template az-variables.tf

vi az-variables.tf

  # change settings
  ...

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
