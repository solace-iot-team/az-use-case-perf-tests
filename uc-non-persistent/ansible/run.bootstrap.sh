#!/bin/bash
# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# ---------------------------------------------------------------------------------------------
clear
echo; echo "##############################################################################################################"
echo

  ############################################################################################################################
  # SELECT
    # ansible
    export ANSIBLE_LOG_PATH="./ansible.log"
    export ANSIBLE_DEBUG=False
    # export ANSIBLE_VERBOSITY=3
    export ANSIBLE_HOST_KEY_CHECKING=False
    # logging: ansible-solace
    export ANSIBLE_SOLACE_LOG_PATH="./ansible-solace.log"
    export ANSIBLE_SOLACE_ENABLE_LOGGING=True

  # END SELECT

##############################################################################################################################
# Prepare

inventory="./inventory/inventory.json"
privateKeyFile="../keys/azure_key"

rm -f ./*.log

##############################################################################################################################
# Generate inventories

  # ./inventory/generate.sh
  ./inventory/generate-with-sc.sh
  if [[ $? != 0 ]]; then echo ">>> ERROR generate inventories. aborting."; echo; exit 1; fi

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
