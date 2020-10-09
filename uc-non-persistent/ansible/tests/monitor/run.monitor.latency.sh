#!/usr/bin/env bash
# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# ---------------------------------------------------------------------------------------------

echo;
echo "##############################################################################################################"
echo "# Running Monitor Latency ..."
echo

  ############################################################################################################################
  # Settings

    scriptDir=$(cd $(dirname "$0") && pwd);
    source $scriptDir/../../.lib/functions.sh
    scriptName=$(basename $(test -L "$0" && readlink "$0" || echo "$0"));
    projectHome=${scriptDir%/ansible/*}
    sharedSetupDir="$projectHome/shared-setup"; [ ! -d $sharedSetupDir ] && (echo ">>> ERROR: directory $sharedSetupDir DOES NOT exists."; exit)

    if [ -z "$RUN_LOG_DIR" ]; then export RUN_LOG_DIR=$scriptDir/tmp; mkdir $RUN_LOG_DIR > /dev/null 2>&1; fi
    export ANSIBLE_LOG_PATH="$RUN_LOG_DIR/$scriptName.ansible.log"
    export ANSIBLE_DEBUG=False
    export ANSIBLE_HOST_KEY_CHECKING=False

############################################################################################################################
# Check if monitor running

############################################################################################################################
# Environment Variables

    if [ -z "$1" ]; then
      if [ -z "$UC_NON_PERSISTENT_INFRASTRUCTURE" ]; then
          echo ">>> ERROR: missing infrastructure info. pass either as env-var: UC_NON_PERSISTENT_INFRASTRUCTURE or as argument"
          echo "    for example: $scriptName azure.infra1-standalone"
          echo; exit 1
      fi
    else
      export UC_NON_PERSISTENT_INFRASTRUCTURE=$1
    fi
    if [ -z "$RUN_ID" ]; then export RUN_ID=$(date -u +"%Y-%m-%d-%H-%M-%S"); fi
    if [ -z "$runStartTsEpochSecs" ]; then export runStartTsEpochSecs=$(date -u +%s); fi

##############################################################################################################################
# Prepare
cloudProvider=${UC_NON_PERSISTENT_INFRASTRUCTURE%%.*}
resultDirBase="$projectHome/test-results/stats/$UC_NON_PERSISTENT_INFRASTRUCTURE"
resultDir="$resultDirBase/run.current"
statsName="latency-stats"
rm -f "$resultDir/$statsName".*.json

##############################################################################################################################
# Run

  inventoryFile=$(assertFile "$sharedSetupDir/$UC_NON_PERSISTENT_INFRASTRUCTURE.inventory.json") || exit
  playbook="$scriptDir/sdkperf.get-latency.playbook.yml"
  privateKeyFile=$(assertFile "$projectHome/keys/"$cloudProvider"_key") || exit

  ansible-playbook \
                  -i $inventoryFile \
                  --private-key $privateKeyFile \
                  $playbook \
                  --extra-vars "RESULT_DIR=$resultDir" \
                  --extra-vars "RUN_ID=$RUN_ID" \
                  --extra-vars "RUN_START_TS_EPOCH_SECS=$runStartTsEpochSecs" \
                  --extra-vars "HOSTS=sdkperf_latency" \
                  --extra-vars "STATS_NAME=$statsName" \
                  --extra-vars "RUN_LOCALLY=False"

  if [[ $? != 0 ]]; then echo ">>> ERROR retrieving latency stats: $scriptName"; echo; exit 1; fi

  echo "##############################################################################################################"
  echo "# Results in: $resultDir"
  echo;echo;

###
# The End.
