# Github Workflows

## GitHub Secrets

### Azure Credentials

#### Generate Azure Service Principal

[See: Generate the Service Principal](https://docs.microsoft.com/en-gb/cli/azure/ad/sp?view=azure-cli-latest#az_ad_sp_create_for_rbac).


````bash
az ad sp create-for-rbac --name "wft-azperf" --sdk-auth

# make a note of the output, similar to this:
{
  "clientId": "{client-id}",
  "clientSecret": "{client-secret}",
  "subscriptionId": "{subscription-id}",
  "tenantId": "{tenant-id}",
  "activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
  "resourceManagerEndpointUrl": "https://management.azure.com/",
  "activeDirectoryGraphResourceId": "https://graph.windows.net/",
  "sqlManagementEndpointUrl": "https://management.core.windows.net:8443/",
  "galleryEndpointUrl": "https://gallery.azure.com/",
  "managementEndpointUrl": "https://management.core.windows.net/"
}

````

#### Github Secrets

  - AZURE_CREDENTIALS = {copy service principal output}
  - AZURE_SUBSCRIPTION_ID = {subscription-id}
  - AZURE_TENANT_ID = {tenant-id}
  - AZURE_CLIENT_ID = {client-id}
  - AZURE_CLIENT_SECRET = {client-secret}


### AWS Credentials

Login into your AWS account and generate: AWS access key id and AWS secret access key.

#### Github Secrets

  - AWS_ACCESS_KEY_ID = {aws access key id}

  - AWS_SECRET_ACCESS_KEY = {aws secret access key}

### Controller VM Keys

#### Generate Keys
````bash
ssh-keygen -t rsa -b 4096 azure_key
````

#### Github Secrets

  - CONTROLLER_VM_PRIVATE_KEY = {contents of azure_key}

  - CONTROLLER_VM_PUBLIC_KEY = {contents of azure_key.pub}

---
THe End.
