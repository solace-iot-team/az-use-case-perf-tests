#!/bin/bash
# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# ---------------------------------------------------------------------------------------------

############################################################################################################################
# Settings
  scriptDir=$(cd $(dirname "$0") && pwd);
  scriptName=$(basename $(test -L "$0" && readlink "$0" || echo "$0"));
  projectHome=${scriptDir%/ansible/*}
  source $scriptDir/../../.lib/functions.sh

  export ANSIBLE_LOG_PATH="./ansible.log"
  export ANSIBLE_DEBUG=False
  export ANSIBLE_VERBOSITY=0
  export ANSIBLE_HOST_KEY_CHECKING=False
  export ANSIBLE_SOLACE_LOG_PATH="./ansible-solace.log"
  export ANSIBLE_SOLACE_ENABLE_LOGGING=True

############################################################################################################################
# Environment Variables

  if [ -z "$1" ]; then
    if [ -z "$UC_NON_PERSISTENT_INFRASTRUCTURE" ]; then
        echo ">>> missing infrastructure info. pass either as env-var: UC_NON_PERSISTENT_INFRASTRUCTURE or as argument"
        echo "    for example: $scriptName azure.infra1-standalone"
        echo; exit 1
    fi
  else
    export UC_NON_PERSISTENT_INFRASTRUCTURE=$1
  fi

##############################################################################################################################
# Prepare

rm -f ./*.log

##############################################################################################################################
# General for all playbooks
inventoryFile=$(assertFile "$scriptDir/../../inventory/$UC_NON_PERSISTENT_INFRASTRUCTURE.inventory.json") || exit
cloudProvider=${UC_NON_PERSISTENT_INFRASTRUCTURE%%.*}
privateKeyFile=$(assertFile "$projectHome/keys/"$cloudProvider"_key") || exit

##############################################################################################################################
# Start SDKPerf Consumers
echo;
echo "######################################"
echo "#                                    #"
echo "#    Starting SDKPerf Consumers      #"
echo "#                                    #"
echo "######################################"

  playbook="$scriptDir/sdkperf.consumer.start.playbook.yml"
  ansible-playbook \
                    -i $inventoryFile \
                    --private-key $privateKeyFile \
                    $playbook
  if [[ $? != 0 ]]; then echo ">>> ERROR. aborting."; echo; exit 1; fi

# Start SDKPerf Publishers
echo;
echo "######################################"
echo "#                                    #"
echo "#    Starting SDKPerf Publishers     #"
echo "#                                    #"
echo "######################################"

  playbook="$scriptDir/sdkperf.publisher.start.playbook.yml"
  ansible-playbook \
                    -i $inventoryFile \
                    --private-key $privateKeyFile \
                    $playbook
  if [[ $? != 0 ]]; then echo ">>> ERROR. aborting."; echo; exit 1; fi



###
# The End.
