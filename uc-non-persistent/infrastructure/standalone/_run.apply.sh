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

  if [ -z "$TERRAFORM_DIR" ]; then echo ">>> ERROR: - $scriptName - missing env var:TERRAFORM_DIR"; exit 1; fi
  if [ -z "$TERRAFORM_VAR_FILE" ]; then echo ">>> ERROR: - $scriptName - missing env var:VARIABLES_FILE"; exit 1; fi
  if [ -z "$TERRAFORM_STATE_FILE" ]; then echo ">>> ERROR: - $scriptName - missing env var:TERRAFORM_STATE_FILE"; exit 1; fi
  if [ -z "$TF_LOG_PATH" ]; then echo ">>> ERROR: - $scriptName - missing env var:TF_LOG_PATH"; exit 1; fi

##############################################################################################################################
# Prepare
  rm -f $TF_LOG_PATH
  # export TF_LOG=INFO

##############################################################################################################################
# Call scripts

  echo ">>> Calling terraform apply, vars=$TERRAFORM_VAR_FILE, state=$TERRAFORM_STATE_FILE"

  cd $TERRAFORM_DIR

  # ignore errors
  terraform taint -state=$TERRAFORM_STATE_FILE null_resource.trigger_bootstrap || true

  terraform apply -state=$TERRAFORM_STATE_FILE -var-file=$TERRAFORM_VAR_FILE -auto-approve
  code=$?; if [[ $code != 0 ]]; then echo ">>> ERROR - $code - $scriptName - executing terraform"; exit 1; fi

  cd $scriptDir


###
# The End.
