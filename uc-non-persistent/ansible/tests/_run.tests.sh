#!/bin/bash
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
      if [ -z "$UC_NON_PERSISTENT_INFRASTRUCTURE" ]; then
          echo ">>> ERROR: missing infrastructure info. pass either as env-var: UC_NON_PERSISTENT_INFRASTRUCTURE or as argument"
          echo "    for example: $scriptName azure.infra1-standalone"
          echo; exit 1
      fi
    else
      export UC_NON_PERSISTENT_INFRASTRUCTURE=$1
    fi

    if [ -z "$RUN_LOG_DIR" ]; then export RUN_LOG_DIR=$scriptDir/tmp; mkdir $RUN_LOG_DIR > /dev/null 2>&1; fi

############################################################################################################################
# Check if any monitors running

monitorPids=( $(ps -ef | grep 'run.monitor' | awk '{ print $2 }') )
let countMonitors=${#monitorPids[@]}
if [ "$countMonitors" -gt 1 ]; then
  echo ">>> ERROR: found running monitors, exiting"; exit 1
fi

echo
echo "##############################################################################################################"
echo "# Running tests: start load, run monitors, stop load ..."
echo


echo ">>> Starting Load ..."
  $scriptDir/load/start.load.sh > $RUN_LOG_DIR/start.load.sh.log
  if [[ $? != 0 ]]; then echo ">>> ERROR starting load"; echo; exit 1; fi

echo ">>> Running Monitors ..."
  $scriptDir/monitor/run.monitor.sh $UC_NON_PERSISTENT_INFRASTRUCTURE auto
  if [[ $? != 0 ]]; then echo ">>> ERROR running monitors"; echo; exit 1; fi

echo ">>> Stop Load ..."
  $scriptDir/load/stop.load.sh > $RUN_LOG_DIR/stop.load.sh.log
  if [[ $? != 0 ]]; then echo ">>> ERROR stopping load"; echo; exit 1; fi

echo " >>> DONE"; echo

###
# The End.
