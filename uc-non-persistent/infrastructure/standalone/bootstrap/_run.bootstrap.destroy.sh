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
# Arguments
  if [ -z "$1" ]; then
      echo ">>> missing infrastructure info. pass as argument"
      echo "    for example: $scriptName azure.infra1-standalone"
      exit 1
  fi
  export UC_NON_PERSISTENT_INFRASTRUCTURE=$1

  if [ -z "$LOG_DIR" ]; then echo ">>> ERROR: - $scriptName - missing env var:LOG_DIR"; exit 1; fi


############################################################################################################################
# Settings

  # tmpDir=$scriptDir/tmp;
  sharedSetupDir="$usecaseHome/shared-setup"; [ ! -d $sharedSetupDir ] && (echo ">>> ERROR: directory $sharedSetupDir DOES NOT exists."; exit)
  # logFileNameBase="$tmpDir/$UC_NON_PERSISTENT_INFRASTRUCTURE.$scriptName"
  logFileNameBase="$LOG_DIR/$UC_NON_PERSISTENT_INFRASTRUCTURE.$scriptName"

  rm -rf "$LOG_DIR/$logFileNameBase"*;

  # mkdir $tmpDir > /dev/null 2>&1;
  # rm -rf "$tmpDir/$logFileNameBase"*;

  export ANSIBLE_LOG_PATH="$logFileNameBase.ansible.log"
  if [ -z "$ANSIBLE_VERBOSITY" ]; then export ANSIBLE_VERBOSITY=0; fi
  export ANSIBLE_HOST_KEY_CHECKING=False
  export ANSIBLE_SOLACE_LOG_PATH="$logFileNameBase.ansible-solace.log"
  if [ -z "$ANSIBLE_SOLACE_ENABLE_LOGGING" ]; then export ANSIBLE_SOLACE_ENABLE_LOGGING=False; fi


##############################################################################################################################
# Run Boostrap Destroy Playbook

  playbook=$(assertFile "$scriptDir/bootstrap.destroy.playbook.yml") || exit
  ansible-playbook \
                    $playbook \
                    --extra-vars "MANIFEST_DEST=$sharedSetupDir/$UC_NON_PERSISTENT_INFRASTRUCTURE.broker.manifest.json"

  code=$?; if [[ $code != 0 ]]; then echo ">>> ERROR - $code - log:$ANSIBLE_LOG_PATH, script:$scriptName, playbook:$playbook"; exit 1; fi


  echo ">>> SUCCESS: $scriptName"


###
# The End.
