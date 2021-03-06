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
  if [ -z "$TEST_SPEC_FILE" ]; then echo ">>> ERROR: missing env var:TEST_SPEC_FILE"; exit 1; fi
  if [ -z "$SHARED_SETUP_DIR" ]; then echo ">>> ERROR: missing env var:SHARED_SETUP_DIR"; exit 1; fi
  if [ -z "$TMP_DIR" ]; then echo ">>> ERROR: missing env var:TMP_DIR"; exit 1; fi

echo "##############################################################################################################"
echo "# Script: $scriptName"

##############################################################################################################################
# Run

  D=$(date -u +"%Y-%m-%d-%H-%M-%S");
  echo ">>> WARNING: tests aborted - $D" > $TMP_DIR/ABORT.log

  playbook="$scriptDir/playbooks/abort.playbook.yml"

  ansible-playbook \
                    -i $TEST_SPEC_INVENTORY_FILE  \
                    $playbook \
                    --extra-vars "SHARED_SETUP_DIR=$SHARED_SETUP_DIR" \
                    --extra-vars "TEST_SPEC_FILE=$TEST_SPEC_FILE"

  code=$?; if [[ $code != 0 ]]; then echo ">>> ERROR - $code - playbook exit: $scriptName"; echo; exit 1; fi

echo ">>> SUCCESS $scriptName"

###
# The End.
