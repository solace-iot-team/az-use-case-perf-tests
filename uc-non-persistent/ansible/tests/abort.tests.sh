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
sharedSetupDir="$projectHome/shared-setup"; [ ! -d $sharedSetupDir ] && (echo ">>> ERROR: directory $sharedSetupDir DOES NOT exists."; exit)

############################################################################################################################
# Environment Variables

    if [ -z "$1" ]; then
      if [ -z "$UC_NON_PERSISTENT_INFRASTRUCTURE" ]; then
          echo ">>> ERROR: missing infrastructure info. pass either as env-var: UC_NON_PERSISTENT_INFRASTRUCTURE or as argument"
          echo "    for example: $scriptName azure.infra1-standalone"
          echo; exit 1
      fi
    else
      export UC_NON_PERSISTENT_INFRASTRUCTURE=$1
    fi

    if [ -z "$RUN_LOG_DIR" ]; then export RUN_LOG_DIR=$scriptDir/tmp; mkdir $RUN_LOG_DIR > /dev/null 2>&1; fi
    if [ -z "$RUN_ID" ]; then D=$(date -u +"%Y-%m-%d-%H-%M-%S"); export RUN_ID=$RUN_ID_PREFIX$D; fi

    export ANSIBLE_LOG_PATH="$RUN_LOG_DIR/$scriptName.ansible.log"
    if [ -z "$ANSIBLE_DEBUG" ]; then export ANSIBLE_DEBUG=False; fi
    export ANSIBLE_HOST_KEY_CHECKING=False

echo
echo "##############################################################################################################"
echo "# Aborting tests for $UC_NON_PERSISTENT_INFRASTRUCTURE"
echo

echo ">>> Shutting down Client Username ..."

inventoryFile=$(assertFile "$sharedSetupDir/$UC_NON_PERSISTENT_INFRASTRUCTURE.inventory.json") || exit
playbook=$(assertFile "$scriptDir/broker.pubsub.shutdown.playbook.yml") || exit
ansible-playbook \
                  -i $inventoryFile \
                  $playbook
code=$?; if [[ $code != 0 ]]; then echo ">>> ERROR - $code - playbook exit: $scriptName"; echo; exit 1; fi
touch $RUN_LOG_DIR/ABORT.log
echo ">>> SUCCESS $scriptName"
###
# The End.
