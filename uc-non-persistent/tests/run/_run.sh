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
      if [ -z "$UC_NON_PERSISTENT_INFRASTRUCTURE" ]; then
          echo ">>> ERROR: missing infrastructure info. pass either as env-var: UC_NON_PERSISTENT_INFRASTRUCTURE or as argument"
          echo "    for example: $scriptName azure.infra1-standalone"
          echo; exit 1
      fi
    else
      export UC_NON_PERSISTENT_INFRASTRUCTURE=$1
    fi

    if [ -z "$RUN_SPEC_FILE" ]; then echo ">>> ERROR: missing env var:RUN_SPEC_FILE"; exit 1; fi
    if [ -z "$RUN_LOG_DIR" ]; then export RUN_LOG_DIR=$scriptDir/tmp; mkdir $RUN_LOG_DIR > /dev/null 2>&1; fi
    if [ -z "$RUN_ID" ]; then D=$(date -u +"%Y-%m-%d-%H-%M-%S"); export RUN_ID=$RUN_ID_PREFIX$D; fi
    if [ -z "$RUN_LOG_FILE_BASE" ]; then echo ">>> ERROR: missing env var:RUN_LOG_FILE_BASE"; exit 1; fi


echo
echo "##############################################################################################################"
echo "# Script: $scriptName"
echo "# Running tests: start load, run monitors, stop load ..."
echo

# echo ">>> Starting Load ..."
#   runScript="$scriptDir/load/start.load.sh"
#   nohup $runScript > $RUN_LOG_DIR/start.load.sh.log 2>&1 &
#   pid="$!"; if wait $pid; then echo ">>> SUCCESS: $runScript"; else echo ">>> ERROR: $runScript"; exit 1; fi

echo ">>> Running Monitors ..."
  runScriptName="_run.monitors.sh"
  logFileName="$RUN_LOG_FILE_BASE.$runScriptName.log"
  runScript="$scriptDir/monitors/$runScriptName auto"
  nohup $runScript > $logFileName 2>&1 &
  pid="$!"; if wait $pid; then echo ">>> SUCCESS: $runScript"; else echo ">>> ERROR: $?: $runScript"; fi

# echo ">>> Stop Load ..."
#   runScript="$scriptDir/load/stop.load.sh"
#   nohup $runScript > $RUN_LOG_DIR/stop.load.sh.log 2>&1 &
#   pid="$!"; if wait $pid; then echo ">>> SUCCESS: $runScript"; else echo ">>> ERROR: $runScript"; exit 1; fi

##############################################################################################################################
# Post Processing of Results
echo ">>> Post processing results ..."
  runScriptName="post-process-results.sh"
  runScript="$scriptDir/lib/$runScriptName"
  logFileName="$RUN_LOG_FILE_BASE.$runScriptName.log"
  nohup $runScript > $logFileName 2>&1 &
  pid="$!"; if wait $pid; then echo ">>> SUCCESS: $runScript"; else echo ">>> ERROR: $?: $runScript"; exit 1; fi

echo ">>> DONE."
if [ -f "$RUN_LOG_FILE_BASE*ERROR.log" ]; then
  echo ">>> ERROR: see: $RUN_LOG_FILE_BASE*ERROR.log"
else
  echo ">>> SUCCESS: no errors found"
fi

###
# The End.
