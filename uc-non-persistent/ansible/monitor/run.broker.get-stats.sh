#!/bin/bash
# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# ---------------------------------------------------------------------------------------------

############################################################################################################################
# Functions
function assertFile() {
  local file=$1
  if [[ ! -f "$file" ]]; then
    echo ">>> ERR: file='$file' does not exist. aborting." > /dev/tty
    echo > /dev/tty
    return 1;
  fi
  echo $file
  return 0
}
# End Functions

clear
echo;
echo "##############################################################################################################"
echo "# Retrieving VPN Stats ..."
echo

  ############################################################################################################################
  # SELECT

    scriptDir=$(cd $(dirname "$0") && pwd);
    scriptName=$(basename $(test -L "$0" && readlink "$0" || echo "$0"));
    projectHome=${scriptDir%%/ansible/*}
    resultDir="$projectHome/test-results/stats"

    brokerNodesFile=$(assertFile "$scriptDir/../../shared-setup/broker-nodes.json") || exit
    sdkPerfNodesFile=$(assertFile "$scriptDir/../../shared-setup/sdkperf-nodes.json") || exit

    # logging & debug: ansible
    export ANSIBLE_LOG_PATH="./ansible.log"
    export ANSIBLE_DEBUG=False
    # # logging: ansible-solace
    # export ANSIBLE_SOLACE_LOG_PATH="./ansible-solace.log"
    # export ANSIBLE_SOLACE_ENABLE_LOGGING=True
    #
    # export ANSIBLE_HOST_KEY_CHECKING=False


  # END SELECT

##############################################################################################################################
# Prepare

rm -f ./*.log

##############################################################################################################################
# Run SDKPerf VM bootstrap

  inventory="../inventory/inventory.json"
  playbook="./broker.get-stats.playbook.yml"

  ansible-playbook \
                    -i $inventory \
                    $playbook \
                    --extra-vars "RESULT_DIR=$resultDir" \
                    --extra-vars "BROKER_NODES_FILE=$brokerNodesFile" \
                    --extra-vars "SDKPERF_NODES_FILE=$sdkPerfNodesFile" \
                    # -vvv

  if [[ $? != 0 ]]; then echo ">>> ERROR retrieving stats."; echo; exit 1; fi

  echo "##############################################################################################################"
  echo "# Stats in: $resultDir/run.{last time stamp}"
  echo;echo;

###
# The End.
