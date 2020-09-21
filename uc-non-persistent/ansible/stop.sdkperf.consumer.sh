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
    # logging & debug: ansible
    export ANSIBLE_LOG_PATH="./ansible.log"
    export ANSIBLE_DEBUG=False
    # logging: ansible-solace
    export ANSIBLE_SOLACE_LOG_PATH="./ansible-solace.log"
    export ANSIBLE_SOLACE_ENABLE_LOGGING=True

    export ANSIBLE_HOST_KEY_CHECKING=False

  # END SELECT

##############################################################################################################################
echo; 
echo "######################################"
echo "#                                    #"
echo "#    Stopping SDKPerf Consumers      #"
echo "#                                    #"
echo "######################################"



  inventory="./inventory/inventory.json"
  playbook="./sdkperf.consumer.stop.playbook.yml"
  privateKeyFile="../keys/azure_key"

  ansible-playbook \
                    -i $inventory \
                    --private-key $privateKeyFile \
                    $playbook \
                    # -vvv

  if [[ $? != 0 ]]; then echo ">>> ERROR. aborting."; echo; exit 1; fi




###
# The End.
