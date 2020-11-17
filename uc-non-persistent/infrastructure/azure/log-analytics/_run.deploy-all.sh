#!/usr/bin/env bash
# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# ---------------------------------------------------------------------------------------------

##############################################################################################################################
# Prepare
scriptDir=$(cd $(dirname "$0") && pwd);
scriptName=$(basename $(test -L "$0" && readlink "$0" || echo "$0"));
projectHome=${scriptDir%/uc-non-persistent/*}
usecaseHome=$projectHome/uc-non-persistent
source $projectHome/.lib/functions.sh

############################################################################################################################
# Environment Variables

  if [ -z "$INFRASTRUCTURE_IDS" ]; then echo ">>> ERROR: - $scriptName - missing env var:INFRASTRUCTURE_IDS"; exit 1; fi
  if [ -z "$LOG_DIR" ]; then echo ">>> ERROR: - $scriptName - missing env var:LOG_DIR"; exit 1; fi

##############################################################################################################################
# Settings

  sharedSetupDir=$usecaseHome/shared-setup

##############################################################################################################################
# Checks

  for infrastructureId in ${INFRASTRUCTURE_IDS[@]}; do
    idArr=(${infrastructureId//./ })
    len=${#idArr[@]}
    if [ $len -ne 2 ]; then echo ">>> ERROR: malformatted infrastructureId='$infrastructureId'"; exit 1; fi
    cloudProvider=${idArr[0]}
    infraConfig=${idArr[1]}

    if [[ "$cloudProvider" != "azure" ]]; then echo ">>> ERROR: - $scriptName - cloud provider: '$cloudProvider' is not 'azure'"; exit 1; fi

    brokerNodesFile=$(assertFile "$sharedSetupDir/$infrastructureId.broker-nodes.json") || exit
    sdkPerfNodesFile=$(assertFile "$sharedSetupDir/$infrastructureId.sdkperf-nodes.json") || exit
    envFile=$(assertFile "$sharedSetupDir/$infrastructureId.env.json") || exit

  done

##############################################################################################################################
# Call scripts

  callScript="_run.deploy.sh"

  for infrastructureId in ${INFRASTRUCTURE_IDS[@]}; do
    idArr=(${infrastructureId//./ })
    cloudProvider=${idArr[0]}
    infraConfig=${idArr[1]}
    echo ">>> Create log analytics deployment for $infraConfig on $cloudProvider ..."

      export CLOUD_PROVIDER_ID=$cloudProvider
      export INFRA_CONFIG_ID=$infraConfig
      export BROKER_NODES_FILE=$brokerNodesFile
      export SDKPERF_NODES_FILE=$sdkPerfNodesFile
      export ENV_FILE=$envFile

      nohup $scriptDir/$callScript > $LOG_DIR/$infrastructureId.$callScript.out 2>&1 &
      scriptPids+=" $!"

  done

##############################################################################################################################
# wait for all jobs to finish

  wait ${scriptPids[*]}

##############################################################################################################################
# Check for errors

  filePattern="$LOG_DIR/*.$callScript.out"
  errors=$(grep -n -e "ERROR" $filePattern )

  if [ -z "$errors" ]; then
    echo ">>> FINISHED:SUCCESS - $scriptName";
    touch "$LOG_DIR/$callScript.SUCCESS.out"
  else
    echo ">>> FINISHED:FAILED";

    while IFS= read line; do
      echo $line >> "$LOG_DIR/$callScript.ERROR.out"
    done < <(printf '%s\n' "$errors")

    exit 1
  fi


###
# The End.
