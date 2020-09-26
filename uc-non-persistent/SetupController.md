# Setup an Ansible Controller VM

## Azure

### VM
For example, use this ARM template to create the Ubuntu VM:

https://azure.microsoft.com/en-gb/resources/templates/101-vm-simple-linux/

Tested with: **Ubuntu 18.04.5 LTS**.

Make a note of the public IP address.

#### ssh into the vm
````bash
ssh {root-user}@{public-ip-address}
````

### Python, Ansible, Ansible-Solace

[Follow the sample instructions for Ubuntu here](https://github.com/solace-iot-team/ansible-solace/blob/master/Install.md).

### Azure CLI
````bash
 curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

 az login

 # use the URL displayed and paste the code to sign in

 # displays subscription info:
 export ARM_SUBSCRIPTION_ID={subscription-id}
 export ARM_TENANT_ID={tenant-id}

````

### Terraform

````bash
wget https://releases.hashicorp.com/terraform/0.13.3/terraform_0.13.3_linux_amd64.zip
sudo apt install unzip
unzip {terraform zip file}
sudo cp terraform /usr/local/bin
terraform version
````

### Solace Docker Image

````bash
wget -O solace-pubsub-evaluation-xxx-docker.tar.gz https://products.solace.com/download/PUBSUB_DOCKER_EVAL
# change xxx with the version number:
tar --extract --file=solace-pubsub-docker.tar.gz manifest.json
cat manifest.json | jq
````

### Solace SDKPerf Image

````bash
wget -O pubSubTools.tar.gz https://products.solace.com/download/SDKPERF_C_LINUX64
tar -xvf pubSubTools.tar.gz
````

## Clone the Project

````bash
git clone https://github.com/solace-iot-team/az-use-case-perf-tests.git
````


---
The End.
