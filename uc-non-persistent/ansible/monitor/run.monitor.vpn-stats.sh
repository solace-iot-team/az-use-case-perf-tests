#!/bin/bash
# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# ---------------------------------------------------------------------------------------------

clear
echo;
echo "##############################################################################################################"
echo "# Running Monitor VPN Stats ..."
echo

  ############################################################################################################################
  # SELECT

    scriptDir=$(cd $(dirname "$0") && pwd);
    source ./.lib/functions.sh
    scriptName=$(basename $(test -L "$0" && readlink "$0" || echo "$0"));
    projectHome=${scriptDir%/ansible/*}
    resultDirBase="$projectHome/test-results/stats"
    resultDir="$resultDirBase/run.latest"

    brokerNodesFile=$(assertFile "$projectHome/shared-setup/broker-nodes.json") || exit
    sdkPerfNodesFile=$(assertFile "$projectHome/shared-setup/sdkperf-nodes.json") || exit

    # logging & debug: ansible
    export ANSIBLE_LOG_PATH="./ansible.log"
    export ANSIBLE_DEBUG=False
    # # logging: ansible-solace
    # export ANSIBLE_SOLACE_LOG_PATH="./ansible-solace.log"
    # export ANSIBLE_SOLACE_ENABLE_LOGGING=True
    #
    # export ANSIBLE_HOST_KEY_CHECKING=False


  # END SELECT

##############################################################################################################################
# Prepare

rm -f $resultDir/vpn-stats.*.json

##############################################################################################################################
# Run SDKPerf VM bootstrap

  inventory="../inventory/inventory.json"
  playbook="./broker.get-stats.playbook.yml"

# nohup ansible-playbook main.yml &
  ansible-playbook \
                  -i $inventory \
                  $playbook \
                  --extra-vars "RESULT_DIR=$resultDir" \
                  --extra-vars "BROKER_NODES_FILE=$brokerNodesFile" \
                  --extra-vars "SDKPERF_NODES_FILE=$sdkPerfNodesFile" \
                  -vvv

  if [[ $? != 0 ]]; then echo ">>> ERROR retrieving VPN stats: $scriptName"; echo; exit 1; fi

  echo "##############################################################################################################"
  echo "# Results in: $resultDir"
  echo;echo;

###
# The End.
