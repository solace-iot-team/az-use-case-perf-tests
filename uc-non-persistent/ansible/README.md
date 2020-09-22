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
- Make a note of the image name and tag:
  ````bash
  cd docker-image
  tar --extract --file=solace-pubsub-docker.tar.gz manifest.json
  cat manifest.json | jq
  # jot down:
  # RepoTags: image name and tag/version
  cd ..
  ````

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

#### Login to the Broker Console

Get the public ip address of the broker node:
````bash
less {root}/shared-setup/broker-nodes.json

````

In Incognito / Private Browser Window:
```
http://{broker-node-public-ip-address}:8080

user: admin
pass: admin
```

## Run Load

### Configure
````bash
cd vars
vi sdkperf.vars.yml
# customize the following:
client_connection_count: 1 # 1 || 10 || 100 || 1000 || etc...
msg_payload_size_bytes: 100 # 100 || 1000 || 10000 || etc...
# total_msg_number:
msg_number: 100000000000 # how many total messages to send, but we don't want our test to stop until we tell it to via kill -2
# 0=max
msg_rate_per_second: 200000
# msg_rate_per_second: 160000 
# msg_rate_per_second: 100000
````


### Run
````bash
./run.load.sh
````

## Run Monitor Stats

[Monitor Readme](./monitor).

````bash
cd monitor
# follow instructions in the README
````

---
The End.
