#!/bin/bash
# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# ---------------------------------------------------------------------------------------------

clear
echo;
echo "##############################################################################################################"
echo "# Running Monitor Brokernode Latency ..."
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

rm -f $resultDir/latency-brokernode-stats.*.log

##############################################################################################################################
# Run SDKPerf Latency

  inventory="../inventory/inventory.json"
  playbook="./sdkperf.get-latency.brokernode.playbook.yml"
  privateKeyFile="$projectHome/keys/azure_key"

  ansible-playbook \
                  -i $inventory \
                  --private-key $privateKeyFile \
                  $playbook \
                  --extra-vars "RESULT_DIR=$resultDir" \
                  # -vvv

  if [[ $? != 0 ]]; then echo ">>> ERROR retrieving latency stats: $scriptName"; echo; exit 1; fi

  echo "##############################################################################################################"
  echo "# Results in: $resultDir"
  echo;echo;

###
# The End.
