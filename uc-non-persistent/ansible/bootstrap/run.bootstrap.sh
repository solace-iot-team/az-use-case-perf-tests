#!/usr/bin/env bash
# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# ---------------------------------------------------------------------------------------------

echo "##############################################################################################################"
echo

############################################################################################################################
# Settings
  scriptDir=$(cd $(dirname "$0") && pwd);
  source $scriptDir/../.lib/functions.sh
  scriptName=$(basename $(test -L "$0" && readlink "$0" || echo "$0"));
  projectHome=${scriptDir%/ansible/*}
  sharedSetupDir="$projectHome/shared-setup"; [ ! -d $sharedSetupDir ] && (echo ">>> ERROR: directory $sharedSetupDir DOES NOT exists."; exit)

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
# Generate inventory

  # move to terraform scripts
  # $scriptDir/inventory/generate.sh
  # if [[ $? != 0 ]]; then echo ">>> ERROR generate inventories. aborting."; echo; exit 1; fi

##############################################################################################################################
# Prepare

rm -f ./*.log

##############################################################################################################################
# General for all playbooks
inventoryFile=$(assertFile "$sharedSetupDir/$UC_NON_PERSISTENT_INFRASTRUCTURE.inventory.json") || exit
cloudProvider=${UC_NON_PERSISTENT_INFRASTRUCTURE%%.*}
privateKeyFile=$(assertFile "$projectHome/keys/"$cloudProvider"_key") || exit

##############################################################################################################################
# Checks
  playbook=$(assertFile "$scriptDir/check.env.playbook.yml") || exit
  ansible-playbook \
                    -i $inventoryFile \
                    --private-key $privateKeyFile \
                    $playbook
  if [[ $? != 0 ]]; then echo ">>> ERROR. aborting."; echo; exit 1; fi

##############################################################################################################################
# Run SDKPerf VM bootstrap
  playbook=$(assertFile "$scriptDir/sdkperf.centos.bootstrap.playbook.yml") || exit
  ansible-playbook \
                    -i $inventoryFile \
                    --private-key $privateKeyFile \
                    $playbook
  if [[ $? != 0 ]]; then echo ">>> ERROR. aborting."; echo; exit 1; fi

##############################################################################################################################
# Run Broker VM bootstrap

  playbook=$(assertFile "$scriptDir/broker.centos.bootstrap.playbook.yml") || exit
  ansible-playbook \
                    -i $inventoryFile \
                    --private-key $privateKeyFile \
                    $playbook
  if [[ $? != 0 ]]; then echo ">>> ERROR. aborting."; echo; exit 1; fi

##############################################################################################################################
# Run Broker PubSub bootstrap

  playbook=$(assertFile "$scriptDir/broker.pubsub.bootstrap.playbook.yml") || exit
  ansible-playbook \
                    -i $inventoryFile \
                    $playbook
  if [[ $? != 0 ]]; then echo ">>> ERROR. aborting."; echo; exit 1; fi

##############################################################################################################################
# Initializing load

$scriptDir/../tests/load/start.load.sh
  if [[ $? != 0 ]]; then echo ">>> ERROR. aborting."; echo; exit 1; fi

$scriptDir/../tests/load/stop.load.sh
  if [[ $? != 0 ]]; then echo ">>> ERROR. aborting."; echo; exit 1; fi

# NOTE:
# Starting and stopping load seems sufficient to initialize SDKPerf working correctly on the VMs.
# If this is not the case, re-think the init process.
    #
    # ##############################################################################################################################
    # # Connect Consumer to Broker initially
    #
    #   playbook=$(assertFile "$scriptDir/sdkperf.consumer.init.playbook.yml") || exit
    #   ansible-playbook \
    #                     -i $inventoryFile \
    #                     --private-key $privateKeyFile \
    #                     $playbook
    #   if [[ $? != 0 ]]; then echo ">>> ERROR. aborting."; echo; exit 1; fi
    #
    # ##############################################################################################################################
    # # Connect Publisher once to Broker initially
    #
    #   playbook=$(assertFile "$scriptDir/sdkperf.publisher.init.playbook.yml") || exit
    #   ansible-playbook \
    #                     -i $inventoryFile \
    #                     --private-key $privateKeyFile \
    #                     $playbook
    #   if [[ $? != 0 ]]; then echo ">>> ERROR. aborting."; echo; exit 1; fi
    #
    # ##############################################################################################################################
    # # Connect Latency once to Broker initially
    #
    #   playbook=$(assertFile "$scriptDir/sdkperf.latency.init.playbook.yml") || exit
    #   ansible-playbook \
    #                     -i $inventoryFile \
    #                     --private-key $privateKeyFile \
    #                     $playbook
    #   if [[ $? != 0 ]]; then echo ">>> ERROR. aborting."; echo; exit 1; fi

echo;
echo "##############################################################################################################"
echo " >>> Successfully bootstrap & initialized infrastructure."
echo


###
# The End.
