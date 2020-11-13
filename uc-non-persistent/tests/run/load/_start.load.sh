#!/usr/bin/env bash
# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# ---------------------------------------------------------------------------------------------

echo "##############################################################################################################"
echo "# Starting Load ..."

##############################################################################################################################
# Prepare
scriptDir=$(cd $(dirname "$0") && pwd);
scriptName=$(basename $(test -L "$0" && readlink "$0" || echo "$0"));
projectHome=${scriptDir%/uc-non-persistent/*}
usecaseHome=$projectHome/uc-non-persistent
source $projectHome/.lib/functions.sh

############################################################################################################################
# Arguments & Environment Variables

  if [ -z "$UC_NON_PERSISTENT_INFRASTRUCTURE" ]; then echo ">>> ERROR: missing env var: UC_NON_PERSISTENT_INFRASTRUCTURE"; exit 1; fi
  if [ -z "$RUN_SPEC_FILE" ]; then echo ">>> ERROR: missing env var: RUN_SPEC_FILE"; exit 1; fi
  if [ -z "$SHARED_SETUP_DIR" ]; then echo ">>> ERROR: missing env var: SHARED_SETUP_DIR"; exit 1; fi
  if [ -z "$RUN_LOG_FILE_BASE" ]; then echo ">>> ERROR: missing env var:RUN_LOG_FILE_BASE"; exit 1; fi


############################################################################################################################
# Included?

  if [ -z "$IS_RUN_LOAD" ]; then
    echo ">>> LOAD NOT INCLUDED in run, exiting"
    exit
  fi

############################################################################################################################
# Settings

  export ANSIBLE_LOG_PATH="$RUN_LOG_FILE_BASE.$scriptName.ansible.log"
  export ANSIBLE_DEBUG=False
  export ANSIBLE_HOST_KEY_CHECKING=False

##############################################################################################################################
# General for all playbooks
cloudProvider=${UC_NON_PERSISTENT_INFRASTRUCTURE%%.*}
privateKeyFile=$(assertFile "$usecaseHome/keys/"$cloudProvider"_key") || exit
inventoryFile=$(assertFile "$SHARED_SETUP_DIR/$UC_NON_PERSISTENT_INFRASTRUCTURE.inventory.json") || exit


playbook="$scriptDir/playbooks/sdkperf.latency.playbook.yml"

##############################################################################################################################
# Start SDKPerf Consumers
echo "##############################################################################################################"
echo "# Starting Consumers ..."

  playbook="$scriptDir/playbooks/sdkperf.consumer.start.playbook.yml"
  ansible-playbook \
                    -i $inventoryFile \
                    --private-key $privateKeyFile \
                    $playbook \
                    --extra-vars "RUN_SPEC_FILE=$RUN_SPEC_FILE" \
                    --extra-vars "RUN_LOG_FILE_BASE=$RUN_LOG_FILE_BASE" \
                    --extra-vars "INVENTORY_FILE=$inventoryFile"

  code=$?; if [[ $code != 0 ]]; then echo ">>> ERROR - $code - playbook exit: $scriptName"; echo; exit 1; fi

echo "##############################################################################################################"
echo "# Starting Publishers ..."

  playbook="$scriptDir/playbooks/sdkperf.publisher.start.playbook.yml"
  ansible-playbook \
                    -i $inventoryFile \
                    --private-key $privateKeyFile \
                    $playbook \
                    --extra-vars "RUN_SPEC_FILE=$RUN_SPEC_FILE" \
                    --extra-vars "RUN_LOG_FILE_BASE=$RUN_LOG_FILE_BASE"

  code=$?; if [[ $code != 0 ]]; then echo ">>> ERROR - $code - playbook exit: $scriptName"; echo; exit 1; fi

###
# The End.
