#!/usr/bin/env bash
# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# ---------------------------------------------------------------------------------------------

############################################################################################################################
# Settings
  scriptDir=$(cd $(dirname "$0") && pwd);
  source $scriptDir/../../.lib/functions.sh
  scriptName=$(basename $(test -L "$0" && readlink "$0" || echo "$0"));
  projectHome=${scriptDir%/ansible/*}
  sharedSetupDir="$projectHome/shared-setup"; [ ! -d $sharedSetupDir ] && (echo ">>> ERROR: directory $sharedSetupDir DOES NOT exists."; exit)

  if [ -z "$RUN_LOG_DIR" ]; then export RUN_LOG_DIR=$scriptDir/tmp; mkdir $RUN_LOG_DIR > /dev/null 2>&1; fi
  export ANSIBLE_LOG_PATH="$RUN_LOG_DIR/$scriptName.ansible.log"
  export ANSIBLE_DEBUG=False
  export ANSIBLE_HOST_KEY_CHECKING=False

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

##############################################################################################################################
# Prepare

# rm -f ./*.log

##############################################################################################################################
# General for all playbooks
inventoryFile=$(assertFile "$sharedSetupDir/$UC_NON_PERSISTENT_INFRASTRUCTURE.inventory.json") || exit
cloudProvider=${UC_NON_PERSISTENT_INFRASTRUCTURE%%.*}
privateKeyFile=$(assertFile "$projectHome/keys/"$cloudProvider"_key") || exit

##############################################################################################################################
# Stop SDKPerf Publishers
  echo;
  echo "######################################"
  echo "#                                    #"
  echo "#    Stopping SDKPerf Publishers     #"
  echo "#                                    #"
  echo "######################################"

    playbook="$scriptDir/sdkperf.publisher.stop.playbook.yml"
    ansible-playbook \
                      -i $inventoryFile \
                      --private-key $privateKeyFile \
                      $playbook
    if [[ $? != 0 ]]; then echo ">>> ERROR. aborting."; echo; exit 1; fi

##############################################################################################################################
# Stop SDKPerf Consumers
  echo;
  echo "######################################"
  echo "#                                    #"
  echo "#    Stopping SDKPerf Consumers      #"
  echo "#                                    #"
  echo "######################################"

    playbook="$scriptDir/sdkperf.consumer.stop.playbook.yml"
    ansible-playbook \
                      -i $inventoryFile \
                      --private-key $privateKeyFile \
                      $playbook
    if [[ $? != 0 ]]; then echo ">>> ERROR. aborting."; echo; exit 1; fi

###
# The End.
