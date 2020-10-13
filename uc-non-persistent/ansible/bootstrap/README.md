# Boostrap Infrastructure

## Change Directory
````bash
# execute all commands in this directory
cd {root}/uc-non-persistent/ansible/bootstrap
````
## Pre-requisites

[Setup Controller VM in Azure](/infrastructure/controller/azure).

#### Solace Docker Image

Ensure the two following files / links are present:
````bash
ls {root}/bin/pubsub/solace-pubsub-docker.tar.gz
ls {root}/bin/pubsub/manifest.json
````

#### Solace SDKPerf executables

The project includes an SDKPerf distribution.

[See here for more information](./sdk-perf-image).

## Configure

````bash
cd ../vars
vi bootstrap.vars.yml

    # make sure this is the user create in the VMs
    docker_centos_users: ["centos"]
````

````bash
cd ../docker-image
less PubSub.docker-compose.template.yml
  # make adjustments to experiment with different settings

````

## Bootstrap
Configures the VMs with their respective software.
#### Inputs Required

[Keys](../../keys) |
[Shared Setup](../../shared-setup)

#### Run Bootstrap
````bash
export UC_NON_PERSISTENT_INFRASTRUCTURE={cloud-provider}.{infrastructure-id}
# for example:
export UC_NON_PERSISTENT_INFRASTRUCTURE=azure.infra1-standalone
./run.bootstrap.sh
````
Or, pass the infrastrucure as an argument:
````bash
./run.bootstrap.sh azure.infra1-standalone
````

#### Login to the Standalone Broker Console

Get the public ip address of the broker node:
````bash
less {root}/shared-setup/{cloud-provider}.{infrastructure-id}.broker-nodes.json
````

In Incognito / Private Browser Window:
```
http://{broker-node-public-ip-address}:8080

user: admin
pass: admin
```

#### Login to the Solace Cloud Broker Console

Use your standard login credentails.

Service: **az_use_case_perf_tests**

---
The End.
