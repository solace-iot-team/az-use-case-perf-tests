#!/bin/bash
# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# ---------------------------------------------------------------------------------------------

echo;
echo "##############################################################################################################"
echo "# Running Monitor Latency ..."
echo

  ############################################################################################################################
  # SELECT

    scriptDir=$(cd $(dirname "$0") && pwd);
    source $scriptDir/.lib/functions.sh
    scriptName=$(basename $(test -L "$0" && readlink "$0" || echo "$0"));
    projectHome=${scriptDir%/ansible/*}
    resultDirBase="$projectHome/az/test-results/stats"
    resultDir="$resultDirBase/az/run.current"

    brokerNodesFile=$(assertFile "$projectHome/shared-setup/az.broker-nodes.json") || exit
    sdkPerfNodesFile=$(assertFile "$projectHome/shared-setup/az.sdkperf-nodes.json") || exit

    # logging & debug: ansible
    export ANSIBLE_LOG_PATH="./az.ansible.log"
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

rm -f $resultDir/az.latency-stats.*.log

##############################################################################################################################
# Run SDKPerf Latency

  inventory="$scriptDir/../inventory/az.inventory.json"
  playbook="$scriptDir/sdkperf.get-latency.playbook.yml"
  privateKeyFile="$projectHome/keys/az_key"

  ansible-playbook \
                  -i $inventory \
                  --private-key $privateKeyFile \
                  $playbook \
                  --extra-vars "RESULT_DIR=$resultDir" \
                  --extra-vars "RUN_ID=$runId"

  if [[ $? != 0 ]]; then echo ">>> ERROR retrieving latency stats: $scriptName"; echo; exit 1; fi

  echo "##############################################################################################################"
  echo "# Results in: $resultDir"
  echo;echo;

###
# The End.
