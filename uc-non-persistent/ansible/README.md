# Ansible

Ansible scripts to:
- bootstrap test machines:
  - broker
  - sdk_perf
- run the tests
- ...

## Change Directory
````bash
# execute all commands in this directory
cd {root}/uc-non-persistent/ansible
````
## Pre-requisites

#### Solace docker image
- download: https://products.solace.com/download/PUBSUB_DOCKER_EVAL
````bash
cp {image-file} ./docker-image/solace-pubsub-docker.tar.gz
# or create a link
cd docker-image
ln -s {image-file} solace-pubsub-docker.tar.gz
cd ..
````

Make a note of the image name and tag:
- unzip the tar.gz
- open the manifest

#### Solace SDKPerf executables
- download: https://products.solace.com/download/SDKPERF_C_LINUX64
- unzip the tar.gz
````bash
cp {path}/pubSubTools ./sdk-perf-image/sdkperf-c-x64
# or create a link
cd sdk-perf-image
ln -s {path}/pubSubTools sdkperf-c-x64
cd ..
````

#### Ansible

Install Ansible.

#### Ansible-Solace Modules

[See Ansible-Solace instructions on GitHub](https://github.com/solace-iot-team/ansible-solace).

- python
- ansible-solace

````bash
export ANSIBLE_PYTHON_INTERPRETER={path-to-python-3}
````

#### Misc Tools
- bash
- [jq](https://stedolan.github.io/jq/download/)

## Configure

````bash
cd vars
vi bootstrap.vars.yml

    # make sure this is the user create in the VMs
    docker_centos_users: ["centos"]
    # make sure the docker image info is correct
    solace_image_name: solace-pubsub-evaluation
    solace_image_version: 9.6.0.32
````

````bash
cd docker-image
less PubSub.docker-compose.template.yml
  # make adjustments to experiment with different settings

````

## Bootstrap

Configure the VMs with their respective software.
#### Inputs Required

[Keys](../keys) |
[Shared Setup](../shared-setup)

#### Run Bootstrap
````bash
./run.bootstrap.sh
````

## Run Tests
````bash
./run.tests.sh
````

## See Test Results

````bash
cd {root}/test-results
ls *
````

---
The End.
