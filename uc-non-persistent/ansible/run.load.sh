#!/bin/bash
# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# ---------------------------------------------------------------------------------------------

clear
############################################################################################################################

  # SELECT
    # logging & debug: ansible
    export ANSIBLE_LOG_PATH="./ansible.log"
    export ANSIBLE_DEBUG=False
    # logging: ansible-solace
    export ANSIBLE_SOLACE_LOG_PATH="./ansible-solace.log"
    export ANSIBLE_SOLACE_ENABLE_LOGGING=True

    export ANSIBLE_HOST_KEY_CHECKING=False


    inventory="./inventory/inventory.json"
    privateKeyFile="../keys/azure_key"

  # END SELECT

##############################################################################################################################
# Start SDKPerf Consumers
echo;
echo "######################################"
echo "#                                    #"
echo "#    Starting SDKPerf Consumers      #"
echo "#                                    #"
echo "######################################"

  playbook="./sdkperf.consumer.start.playbook.yml"
  ansible-playbook \
                    -i $inventory \
                    --private-key $privateKeyFile \
                    $playbook \
                    # -vvv

  if [[ $? != 0 ]]; then echo ">>> ERROR. aborting."; echo; exit 1; fi

# Start SDKPerf Publishers
echo;
echo "######################################"
echo "#                                    #"
echo "#    Starting SDKPerf Publishers     #"
echo "#                                    #"
echo "######################################"

  playbook="./sdkperf.publisher.start.playbook.yml"
  ansible-playbook \
                    -i $inventory \
                    --private-key $privateKeyFile \
                    $playbook \
                    # -vvv

  if [[ $? != 0 ]]; then echo ">>> ERROR. aborting."; echo; exit 1; fi



###
# The End.
