# Ansible

Ansible scripts to:
- bootstrap test machines:
  - broker
  - sdk_perf
- run the tests
- ...


## Pre-requisites

#### Solace docker image
- download: https://products.solace.com/download/PUBSUB_DOCKER_EVAL
````bash
cp {image-file} ./docker-image/solace-pubsub-docker.tar.gz
# or create a link
````

#### Solace SDKPerf executables
- download: ??
````bash
cp {the files} ./docker-image/what dir / name?
# or create a link
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

## Bootstrap

Configure the VMs with their respective software.
#### Inputs Required

[Keys](../keys) |
[Shared Setup](./shared-setup)

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
