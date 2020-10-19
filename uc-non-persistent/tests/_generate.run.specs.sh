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
    echo ">>> ERROR: missing test-spec file. use: $scriptName {path}/{spec-id}.test.spec.yml"
    echo; exit 1
  else
    export TEST_SPEC=$1
    x=$(assertFile "$scriptDir/$TEST_SPEC") || exit
  fi

  if [ -z "$TMP_DIR" ]; then export TMP_DIR=$scriptDir/tmp; mkdir $TMP_DIR > /dev/null 2>&1; fi
  


############################################################################################################################
# Generate Run Specs

export ANSIBLE_VERBOSITY=3

playbook="$scriptDir/playbooks/test.spec.controller.playbook.yml"
ansible-playbook \
                $playbook \
                --extra-vars "TEST_SPEC=$scriptDir/$TEST_SPEC" \
                --extra-vars "RUN_LOG_DIR=$RUN_LOG_DIR"

if [[ $? != 0 ]]; then echo ">>> ERROR running: $scriptName"; echo; exit 1; fi



###
# The End.
