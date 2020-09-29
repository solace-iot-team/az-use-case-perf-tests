#!/bin/bash
# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# ---------------------------------------------------------------------------------------------

clear
echo;
echo "##############################################################################################################"
echo "# Running Monitor Ping ..."
echo

  ############################################################################################################################
  # SELECT

    scriptDir=$(cd $(dirname "$0") && pwd);
    source ./.lib/functions.sh
    scriptName=$(basename $(test -L "$0" && readlink "$0" || echo "$0"));
    projectHome=${scriptDir%/ansible/*}
    resultDirBase="$projectHome/test-results/stats"
    resultDir="$resultDirBase/run.current"

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

    if [ -z "$runId" ]; then
      export TZ=UTC0
      export runId=$(date +%Y-%m-%d-%H-%M-%S)
    fi

  # END SELECT

##############################################################################################################################
# Prepare

rm -f $resultDir/ping-stats.*.log

##############################################################################################################################
# Run SDKPerf Latency

  inventory="../inventory/inventory.json"
  playbook="./sdkperf.ping.playbook.yml"
  privateKeyFile="$projectHome/keys/azure_key"

  ansible-playbook \
                  -i $inventory \
                  --private-key $privateKeyFile \
                  $playbook \
                  --extra-vars "RESULT_DIR=$resultDir" \
                  --extra-vars "RUN_ID=$runId"

  if [[ $? != 0 ]]; then echo ">>> ERROR retrieving ping stats: $scriptName"; echo; exit 1; fi

  echo "##############################################################################################################"
  echo "# Results in: $resultDir"
  echo;echo;

###
# The End.
