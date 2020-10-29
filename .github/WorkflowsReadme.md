# Github Workflows

## GitHub Secrets

### Azure Credentials

#### Generate Azure Service Principal

[See: Generate the Service Principal](https://docs.microsoft.com/en-gb/cli/azure/ad/sp?view=azure-cli-latest#az_ad_sp_create_for_rbac).

````bash
#  for example:
az ad sp create-for-rbac
````

#### Github Secrets

AZURE_CREDENTIALS = {copy service principal output}

AZURE_SUBSCRIPTION_ID = {subscription id}

### Controller VM Keys

#### Generate Keys
````bash
ssh-keygen -t rsa -b 4096 azure_key
````

#### Github Secrets

CONTROLLER_VM_PRIVATE_KEY = {contents of azure_key}

CONTROLLER_VM_PUBLIC_KEY = {contents of azure_key.pub}

---
THe End.
