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
  if [ -z "$TF_VARIABLES_DIR" ]; then echo ">>> ERROR: - $scriptName - missing env var:TF_VARIABLES_DIR"; exit 1; fi

##############################################################################################################################
# Checks

  if [ ! -d "$TF_VARIABLES_DIR" ]; then echo ">>> ERROR: - $scriptName - TF_VARIABLES_DIR does not exist, '$TF_VARIABLES_DIR'"; exit 1; fi
  for infrastructureId in ${INFRASTRUCTURE_IDS[@]}; do
    idArr=(${infrastructureId//./ })
    len=${#idArr[@]}
    if [ $len -ne 2 ]; then echo ">>> ERROR: malformatted infrastructureId='$infrastructureId'"; exit 1; fi
    cloudProvider=${idArr[0]}
    infraConfig=${idArr[1]}
    if [ ! -d "$scriptDir/$cloudProvider" ]; then echo ">>> ERROR: - $scriptName - cloudProvider directory does not exist, '$cloudProvider'"; exit 1; fi
    tfVarsFile="$TF_VARIABLES_DIR/$infrastructureId.tfvars.json"
    if [ ! -f "$tfVarsFile" ]; then echo ">>> ERROR: - $scriptName - terraform vars file does not exist, '$tfVarsFile'"; exit 1; fi
  done

##############################################################################################################################
# Call scripts

  callScript=_run.apply.sh

  for infrastructureId in ${INFRASTRUCTURE_IDS[@]}; do
    idArr=(${infrastructureId//./ })
    cloudProvider=${idArr[0]}
    infraConfig=${idArr[1]}
    echo ">>> Standup $infraConfig on $cloudProvider ..."

      export TERRAFORM_DIR="$scriptDir/$cloudProvider"
      export TERRAFORM_VAR_FILE="$TF_VARIABLES_DIR/$infrastructureId.tfvars.json"
      export TERRAFORM_STATE_FILE="tfstate/$infrastructureId.tfstate"

      export TF_LOG_PATH="$LOG_DIR/$infrastructureId.$callScript.terraform.log"

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
