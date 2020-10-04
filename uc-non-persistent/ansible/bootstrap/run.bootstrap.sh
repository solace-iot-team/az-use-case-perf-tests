#!/bin/bash
# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# ---------------------------------------------------------------------------------------------
clear
echo; echo "##############################################################################################################"
echo

############################################################################################################################
# Settings
  scriptDir=$(cd $(dirname "$0") && pwd);
  source $scriptDir/../.lib/functions.sh
  scriptName=$(basename $(test -L "$0" && readlink "$0" || echo "$0"));
  projectHome=${scriptDir%/ansible/*}

  export ANSIBLE_LOG_PATH="./ansible.log"
  export ANSIBLE_DEBUG=False
  # export ANSIBLE_VERBOSITY=3
  export ANSIBLE_HOST_KEY_CHECKING=False
  export ANSIBLE_SOLACE_LOG_PATH="./ansible-solace.log"
  export ANSIBLE_SOLACE_ENABLE_LOGGING=True

############################################################################################################################
# Environment Variables

  if [ -z "$1" ]; then
    if [ -z "$UC_NON_PERSISTENT_INFRASTRUCTURE" ]; then
        echo ">>> missing infrastructure info. pass either as env-var: UC_NON_PERSISTENT_INFRASTRUCTURE or as argument"
        echo "    for example: ./run.bootstrap.sh azure.standalone"
        echo; exit 1
    fi
  else
    export UC_NON_PERSISTENT_INFRASTRUCTURE=$1
  fi

##############################################################################################################################
# Generate inventories

  $scriptDir/../inventory/generate-with-sc.sh
  if [[ $? != 0 ]]; then echo ">>> ERROR generate inventories. aborting."; echo; exit 1; fi

exit
##############################################################################################################################
# Prepare
inventory="./inventory/"$PERF_CLOUDPROVIDER".inventory.json"
privateKeyFile="../keys/"$PERF_CLOUDPROVIDER"_key"

rm -f ./*.log


##############################################################################################################################
# Run SDKPerf VM bootstrap

  playbook="./sdkperf.centos.bootstrap.playbook.yml"
  ansible-playbook \
                    -i $inventory \
                    --private-key $privateKeyFile \
                    $playbook
  if [[ $? != 0 ]]; then echo ">>> ERROR. aborting."; echo; exit 1; fi

##############################################################################################################################
# Run Broker VM bootstrap

  playbook="./broker.centos.bootstrap.playbook.yml"
  ansible-playbook \
                    -i $inventory \
                    --private-key $privateKeyFile \
                    $playbook
  if [[ $? != 0 ]]; then echo ">>> ERROR. aborting."; echo; exit 1; fi

##############################################################################################################################
# Run Broker PubSub bootstrap

  playbook="./broker.pubsub.bootstrap.playbook.yml"
  ansible-playbook \
                    -i $inventory \
                    $playbook
  if [[ $? != 0 ]]; then echo ">>> ERROR. aborting."; echo; exit 1; fi

##############################################################################################################################
# Connect Consumer to Broker initially

  playbook="./sdkperf.consumer.init.playbook.yml"
  ansible-playbook \
                    -i $inventory \
                    --private-key $privateKeyFile \
                    $playbook
  if [[ $? != 0 ]]; then echo ">>> ERROR. aborting."; echo; exit 1; fi

##############################################################################################################################
# Connect Publisher once to Broker initially

  playbook="./sdkperf.publisher.init.playbook.yml"
  ansible-playbook \
                    -i $inventory \
                    --private-key $privateKeyFile \
                    $playbook
  if [[ $? != 0 ]]; then echo ">>> ERROR. aborting."; echo; exit 1; fi

##############################################################################################################################
# Connect Latency once to Broker initially

  playbook="./sdkperf.latency.init.playbook.yml"
  ansible-playbook \
                    -i $inventory \
                    --private-key $privateKeyFile \
                    $playbook
  if [[ $? != 0 ]]; then echo ">>> ERROR. aborting."; echo; exit 1; fi

###
# The End.
