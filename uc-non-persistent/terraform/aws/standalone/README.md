# AWS Infrastructure: Standalone

Creates AWS resources for a standalone Solace broker deployment using terraform.

## AWS Credentials

````bash
export AWS_ACCESS_KEY_ID={aws-access-key}
export AWS_SECRET_ACCESS_KEY={aws-secret-access-key}
export AWS_DEFAULT_REGION={aws-default-region}
````

## Deployment Settings
````bash
cp aws-variables.template aws-variables.tf
vi aws-variables.tf
 # customize settings
````

## Prepare

#### Generate keys

* Name: `aws_key`
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

## Check

````bash
ls ../../../shared-setup/aws.*.broker-nodes.json
ls ../../../shared-setup/aws.*.sdkperf-nodes.json
````

## Destroy
````bash
terraform destroy
````
---
The End.
