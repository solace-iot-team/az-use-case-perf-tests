#!/bin/bash
# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# ---------------------------------------------------------------------------------------------

############################################################################################################################

  # SELECT
    # logging & debug: ansible
    export ANSIBLE_LOG_PATH="./aws.ansible.log"
    export ANSIBLE_DEBUG=False
    # logging: ansible-solace
    export ANSIBLE_SOLACE_LOG_PATH="./aws.ansible-solace.log"
    export ANSIBLE_SOLACE_ENABLE_LOGGING=True
    export PERF_CLOUDPROVIDER=aws
    export ANSIBLE_HOST_KEY_CHECKING=False

    inventory="./inventory/aws.inventory.json"
    privateKeyFile="../keys/aws_key"

  # END SELECT

##############################################################################################################################
# Stop SDKPerf Publishers
  echo;
  echo "######################################"
  echo "#                                    #"
  echo "#    Stopping SDKPerf Publishers     #"
  echo "#                                    #"
  echo "######################################"

    playbook="./sdkperf.publisher.stop.playbook.yml"
    ansible-playbook \
                      -i $inventory \
                      --private-key $privateKeyFile \
                      $playbook \
                      # -vvv

    if [[ $? != 0 ]]; then echo ">>> ERROR. aborting."; echo; exit 1; fi

##############################################################################################################################
# Stop SDKPerf Consumers
  echo;
  echo "######################################"
  echo "#                                    #"
  echo "#    Stopping SDKPerf Consumers      #"
  echo "#                                    #"
  echo "######################################"

    playbook="./sdkperf.consumer.stop.playbook.yml"
    ansible-playbook \
                      -i $inventory \
                      --private-key $privateKeyFile \
                      $playbook \
                      # -vvv

    if [[ $? != 0 ]]; then echo ">>> ERROR. aborting."; echo; exit 1; fi

###
# The End.
