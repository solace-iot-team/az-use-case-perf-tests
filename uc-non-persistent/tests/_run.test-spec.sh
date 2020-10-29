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

  if [ -z "$TEST_SPEC_INVENTORY_FILE" ]; then echo ">>> ERROR: missing env var:TEST_SPEC_INVENTORY_FILE"; exit 1; fi
    x=$(assertFile "$TEST_SPEC_INVENTORY_FILE") || exit

  if [ -z "$TMP_DIR" ]; then echo ">>> ERROR: missing env var:TMP_DIR"; exit 1; fi
  if [ -z "$TEST_SPEC_DIR" ]; then echo ">>> ERROR: missing env var:TEST_SPEC_DIR"; exit 1; fi
  if [ -z "$SHARED_SETUP_DIR" ]; then echo ">>> ERROR: missing env var:SHARED_SETUP_DIR"; exit 1; fi
  if [ -z "$GENERATE_ONLY" ]; then GENERATE_ONLY="False"; fi

##############################################################################################################################
# Prepare

  export RUN_SCRIPTS_DIR=$scriptDir/run
  export RUN_SPECS_DIR=$TMP_DIR/run-specs; mkdir $RUN_SPECS_DIR > /dev/null 2>&1
  rm -f $RUN_SPECS_DIR/*

############################################################################################################################
# Generate Run Specs

playbook="$scriptDir/playbooks/run.test-spec.playbook.yml"
ansible-playbook \
                -i $TEST_SPEC_INVENTORY_FILE  \
                $playbook \
                --extra-vars "SHARED_SETUP_DIR=$SHARED_SETUP_DIR" \
                --extra-vars "LOG_DIR=$TMP_DIR" \
                --extra-vars "RUN_SCRIPTS_DIR=$RUN_SCRIPTS_DIR" \
                --extra-vars "RUN_SPECS_DIR=$RUN_SPECS_DIR" \
                --extra-vars "GENERATE_ONLY=$GENERATE_ONLY"

code=$?; if [[ $code != 0 ]]; then echo ">>> ERROR - $code - playbook exit: $scriptName"; echo; exit 1; fi



###
# The End.
