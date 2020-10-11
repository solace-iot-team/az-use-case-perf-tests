#!/usr/bin/env bash
# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# ---------------------------------------------------------------------------------------------

##############################################################################################################################
# Prepare
scriptDir=$(cd $(dirname "$0") && pwd);
source $scriptDir/../.lib/functions.sh
scriptName=$(basename $(test -L "$0" && readlink "$0" || echo "$0"));
projectHome=${scriptDir%/ansible/*}

############################################################################################################################
# Environment Variables

  if [ -z "$1" ]; then
    echo ">>> ERROR: missing test-spec file. use: $scriptName {path}/{spec-id}.test.spec.yml"
    echo; exit 1
  else
    export TEST_SPEC=$1
    x=$(assertFile "$scriptDir/$TEST_SPEC") || exit
  fi

  if [ -z "$RUN_LOG_DIR" ]; then export RUN_LOG_DIR=$scriptDir/tmp; mkdir $RUN_LOG_DIR > /dev/null 2>&1; fi


############################################################################################################################
# Run Controller

export ANSIBLE_VERBOSITY=3

playbook="$scriptDir/playbooks/test.spec.controller.playbook.yml"
ansible-playbook \
                $playbook \
                --extra-vars "TEST_SPEC=$scriptDir/$TEST_SPEC" \
                --extra-vars "RUN_LOG_DIR=$RUN_LOG_DIR"

if [[ $? != 0 ]]; then echo ">>> ERROR running: $scriptName"; echo; exit 1; fi



###
# The End.
