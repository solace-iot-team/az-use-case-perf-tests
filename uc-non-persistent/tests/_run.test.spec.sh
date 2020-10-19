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

  if [ -z "$1" ]; then
    echo ">>> ERROR: missing test-spec inventory file. use: $scriptName {path}/{spec-id}.test.spec.inventory.json"
    echo; exit 1
  else
    export TEST_SPEC_INVENTORY_FILE=$scriptDir/$1
    x=$(assertFile "$TEST_SPEC_INVENTORY_FILE") || exit
  fi

  if [ -z "$LOG_DIR" ]; then export LOG_DIR=$scriptDir/tmp; mkdir $LOG_DIR > /dev/null 2>&1; fi
  if [ -z "$SHARED_SETUP_DIR" ]; then export SHARED_SETUP_DIR=$usecaseHome/shared-setup; fi
  if [ -z "$RUN_SCRIPTS_DIR" ]; then export RUN_SCRIPTS_DIR=$scriptDir/run; fi
  if [ -z "$RUN_SPECS_DIR" ]; then export RUN_SPECS_DIR=$scriptDir/tmp/run-specs; mkdir $RUN_SPECS_DIR > /dev/null 2>&1; fi


############################################################################################################################
# Generate Run Specs

export ANSIBLE_VERBOSITY=3

playbook="$scriptDir/playbooks/test.specs.controller.playbook.yml"
ansible-playbook \
                -i $TEST_SPEC_INVENTORY_FILE  \
                $playbook \
                --extra-vars "SHARED_SETUP_DIR=$SHARED_SETUP_DIR" \
                --extra-vars "LOG_DIR=$LOG_DIR" \
                --extra-vars "RUN_SCRIPTS_DIR=$RUN_SCRIPTS_DIR" \
                --extra-vars "RUN_SPECS_DIR=$RUN_SPECS_DIR"


if [[ $? != 0 ]]; then echo ">>> ERROR running: $scriptName"; echo; exit 1; fi



###
# The End.
