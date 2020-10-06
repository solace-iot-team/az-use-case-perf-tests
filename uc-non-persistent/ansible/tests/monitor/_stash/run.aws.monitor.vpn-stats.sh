#!/bin/bash
# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# ---------------------------------------------------------------------------------------------

echo;
echo "##############################################################################################################"
echo "# Running Monitor VPN Stats ..."
echo

  ############################################################################################################################
  # SELECT

    scriptDir=$(cd $(dirname "$0") && pwd);
    source $scriptDir/.lib/functions.sh
    scriptName=$(basename $(test -L "$0" && readlink "$0" || echo "$0"));
    projectHome=${scriptDir%/ansible/*}
    resultDirBase="$projectHome/aws/test-results/stats"
    resultDir="$resultDirBase/run.current"

    brokerNodesFile=$(assertFile "$projectHome/shared-setup/aws.broker-nodes.json") || exit
    sdkPerfNodesFile=$(assertFile "$projectHome/shared-setup/aws.sdkperf-nodes.json") || exit

    if [ -z "$runId" ]; then
      export TZ=UTC0
      export runId=$(date +%Y-%m-%d-%H-%M-%S)
    fi

    # logging & debug: ansible
    export ANSIBLE_LOG_PATH="./aws.ansible.log"
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

  inventory="$scriptDir/../inventory/aws.inventory.json"
  playbook="$scriptDir/broker.get-stats.playbook.yml"

# nohup ansible-playbook main.yml &
  ansible-playbook \
                  -i $inventory \
                  $playbook \
                  --extra-vars "RESULT_DIR=$resultDir" \
                  --extra-vars "BROKER_NODES_FILE=$brokerNodesFile" \
                  --extra-vars "SDKPERF_NODES_FILE=$sdkPerfNodesFile" \
                  --extra-vars "RUN_ID=$runId"

  if [[ $? != 0 ]]; then echo ">>> ERROR retrieving VPN stats: $scriptName"; echo; exit 1; fi

  echo "##############################################################################################################"
  echo "# Results in: $resultDir"
  echo;echo;

###
# The End.
