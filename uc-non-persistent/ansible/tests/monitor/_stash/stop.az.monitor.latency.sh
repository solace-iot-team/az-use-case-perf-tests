#!/bin/bash
# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# ---------------------------------------------------------------------------------------------

clear
echo;
echo "##############################################################################################################"
echo "# Stopping Monitor Latency ..."
echo

############################################################################################################################
# Prepare

    scriptDir=$(cd $(dirname "$0") && pwd);
    scriptName=$(basename $(test -L "$0" && readlink "$0" || echo "$0"));
    projectHome=${scriptDir%/ansible/*}

    # logging & debug: ansible
    export ANSIBLE_LOG_PATH="./az.ansible.log"
    export ANSIBLE_DEBUG=False
    # # logging: ansible-solace
    # export ANSIBLE_SOLACE_LOG_PATH="./ansible-solace.log"
    # export ANSIBLE_SOLACE_ENABLE_LOGGING=True
    #
    export ANSIBLE_HOST_KEY_CHECKING=False


##############################################################################################################################
# Run SDKPerf Latency

  inventory="../inventory/az.inventory.json"
  playbook="./sdkperf.latency.stop.playbook.yml"
  privateKeyFile="$projectHome/keys/az_key"

  ansible-playbook \
                  -i $inventory \
                  --private-key $privateKeyFile \
                  $playbook

  if [[ $? != 0 ]]; then echo ">>> ERROR stopping latency jobs: $scriptName"; echo; exit 1; fi


###
# The End.
