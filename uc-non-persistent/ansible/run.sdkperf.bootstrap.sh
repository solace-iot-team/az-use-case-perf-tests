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

rm -f ./*.log

##############################################################################################################################
# Run SDKPerf VM bootstrap

  inventory="./inventory/inventory.json"
  playbook="./sdkperf.centos.bootstrap.playbook.yml"
  privateKeyFile="../keys/azure_key"

  ansible-playbook \
                    -i $inventory \
                    --private-key $privateKeyFile \
                    $playbook \
                    # -vvv

  if [[ $? != 0 ]]; then echo ">>> ERROR. aborting."; echo; exit 1; fi


###
# The End.
