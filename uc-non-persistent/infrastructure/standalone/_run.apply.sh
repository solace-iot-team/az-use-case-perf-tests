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

FAILED=0

############################################################################################################################
# Environment Variables

  if [ -z "$TERRAFORM_DIR" ]; then echo ">>> ERROR: - $scriptName - missing env var:TERRAFORM_DIR"; FAILED=1; fi
  if [ -z "$TERRAFORM_VAR_FILE" ]; then echo ">>> ERROR: - $scriptName - missing env var:VARIABLES_FILE"; FAILED=1; fi
  if [ -z "$TERRAFORM_STATE_FILE" ]; then echo ">>> ERROR: - $scriptName - missing env var:TERRAFORM_STATE_FILE"; FAILED=1; fi

##############################################################################################################################
# Prepare
  export TMP_DIR=$scriptDir/tmp;
    mkdir $TMP_DIR > /dev/null 2>&1;
    rm -rf $TMP_DIR/*;

##############################################################################################################################
# Call scripts

if [ "$FAILED" -eq 0 ]; then
  echo ">>> Calling terraform apply, vars=$TERRAFORM_VAR_FILE, state=$TERRAFORM_STATE_FILE"
  cd $TERRAFORM_DIR

  terraform apply -state=$TERRAFORM_STATE_FILE -var-file=$TERRAFORM_VAR_FILE -auto-approve
  code=$?; if [[ $code != 0 ]]; then echo ">>> ERROR - $code - $scriptName - executing terraform"; FAILED=1; fi

  cd $scriptDir
fi



##############################################################################################################################
# Workflow output

  if [ "$FAILED" -gt 0 ]; then
    echo ">>> FINISHED:FAILED - $scriptName"; exit 1
  else
    echo ">>> FINISHED:SUCCESS - $scriptName";
  fi

###
# The End.
