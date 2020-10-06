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
# Settings

  scriptDir=$(cd $(dirname "$0") && pwd);
  source $scriptDir/../../.lib/functions.sh
  scriptName=$(basename $(test -L "$0" && readlink "$0" || echo "$0"));
  projectHome=${scriptDir%/ansible/*}
  sharedSetupDir="$projectHome/shared-setup"; [ ! -d $sharedSetupDir ] && (echo ">>> ERROR: directory $sharedSetupDir DOES NOT exists."; exit)

  export ANSIBLE_LOG_PATH="./ansible.log"
  export ANSIBLE_DEBUG=False
  export ANSIBLE_HOST_KEY_CHECKING=False

############################################################################################################################
# Environment Variables

    if [ -z "$1" ]; then
      if [ -z "$UC_NON_PERSISTENT_INFRASTRUCTURE" ]; then
          echo ">>> missing infrastructure info. pass either as env-var: UC_NON_PERSISTENT_INFRASTRUCTURE or as argument"
          echo "    for example: $scriptName azure.infra1-standalone"
          echo; exit 1
      fi
    else
      export UC_NON_PERSISTENT_INFRASTRUCTURE=$1
    fi

    if [ -z "$runId" ]; then
      export runId=$(date -u +%Y-%m-%d-%H-%M-%S)
    fi

    if [ -z "$runStartTsEpochSecs" ]; then
      export runStartTsEpochSecs=$(date -u +%s)
    fi

##############################################################################################################################
# Prepare
cloudProvider=${UC_NON_PERSISTENT_INFRASTRUCTURE%%.*}
resultDirBase="$projectHome/test-results/stats/$UC_NON_PERSISTENT_INFRASTRUCTURE"
resultDir="$resultDirBase/run.current"
statsName="vpn-stats"
rm -f "$resultDir/$statsName".*.json
brokerNodesFile=$(assertFile "$projectHome/shared-setup/$UC_NON_PERSISTENT_INFRASTRUCTURE.broker-nodes.json") || exit
sdkPerfNodesFile=$(assertFile "$projectHome/shared-setup/$UC_NON_PERSISTENT_INFRASTRUCTURE.sdkperf-nodes.json") || exit


##############################################################################################################################
# Run

  inventoryFile=$(assertFile "$sharedSetupDir/$UC_NON_PERSISTENT_INFRASTRUCTURE.inventory.json") || exit
  playbook="$scriptDir/broker.get-stats.playbook.yml"
  privateKeyFile=$(assertFile "$projectHome/keys/"$cloudProvider"_key") || exit

  ansible-playbook \
                  -i $inventoryFile \
                  --private-key $privateKeyFile \
                  $playbook \
                  --extra-vars "RESULT_DIR=$resultDir" \
                  --extra-vars "RUN_ID=$runId" \
                  --extra-vars "RUN_START_TS_EPOCH_SECS=$runStartTsEpochSecs" \
                  --extra-vars "STATS_NAME=$statsName" \
                  --extra-vars "BROKER_NODES_FILE=$brokerNodesFile" \
                  --extra-vars "SDKPERF_NODES_FILE=$sdkPerfNodesFile" \

  if [[ $? != 0 ]]; then echo ">>> ERROR retrieving vpn stats: $scriptName"; echo; exit 1; fi

echo "##############################################################################################################"
echo "# Results in: $resultDir"
echo;echo;

###
# The End.
