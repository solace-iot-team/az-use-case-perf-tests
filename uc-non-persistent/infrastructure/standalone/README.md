# Infrastructure : Standalone

Infrastructure standup and destroy for standalone Solace PubSub+ Broker.

## Pre-requisites

### General
#### Keys

[See here](../../kesy).

#### Ansible Python Interpreter

````bash
export ANSIBLE_PYTHON_INTERPRETER={path-to-python-3}
````

### Azure Credentials

````bash
az login

export ARM_SUBSCRIPTION_ID={subscription-id}
export ARM_TENANT_ID={tenant-id}
````


### AWS Credentials

````bash
export AWS_ACCESS_KEY_ID={aws-access-key}
export AWS_SECRET_ACCESS_KEY={aws-secret-access-key}
export AWS_DEFAULT_REGION={aws-default-region}
````

## Run

[Auto-Run Examples](./auto-run).


---
The End.
