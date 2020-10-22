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

  if [ -z "$UC_NON_PERSISTENT_INFRASTRUCTURE" ]; then echo ">>> ERROR: missing env var:UC_NON_PERSISTENT_INFRASTRUCTURE"; exit 1; fi
  if [ -z "$RUN_SPEC_FILE" ]; then echo ">>> ERROR: missing env var:RUN_SPEC_FILE"; exit 1; fi
  if [ -z "$RUN_ID" ]; then echo ">>> ERROR: missing env var:RUN_ID"; exit 1; fi
  if [ -z "$RUN_NAME" ]; then echo ">>> ERROR: missing env var:RUN_NAME"; exit 1; fi
  if [ -z "$RUN_LOG_FILE_BASE" ]; then echo ">>> ERROR: missing env var:RUN_LOG_FILE_BASE"; exit 1; fi
  if [ -z "$RUN_START_TS_EPOCH_SECS" ]; then echo ">>> ERROR: missing env var:RUN_START_TS_EPOCH_SECS"; exit 1; fi

##############################################################################################################################
# Prepare
resultDirBase="$usecaseHome/test-results/stats/$UC_NON_PERSISTENT_INFRASTRUCTURE"
resultDir="$resultDirBase/run.current"

mkdir $resultDirBase > /dev/null 2>&1
mkdir $resultDir > /dev/null 2>&1
rm -f $resultDir/*

echo
echo "##############################################################################################################"
echo "# Script: $scriptName"
echo "# Running tests: start load, run monitors, stop load ..."
echo

echo ">>> Pre-Run processing ..."
  runScriptName="_run.pre-run.sh"
  logFileName="$RUN_LOG_FILE_BASE.$runScriptName.log"
  runScript="$scriptDir/$runScriptName"
  nohup $runScript > $logFileName 2>&1 &
  pid="$!"; if wait $pid; then echo ">>> SUCCESS: $runScript"; else echo ">>> ERROR: $?: $runScript"; exit 1; fi

echo ">>> Starting Load ..."
  runScriptName="_start.load.sh"
  logFileName="$RUN_LOG_FILE_BASE.$runScriptName.log"
  runScript="$scriptDir/load/$runScriptName"
  nohup $runScript > $logFileName 2>&1 &
  pid="$!"; if wait $pid; then echo ">>> SUCCESS: $runScript"; else echo ">>> ERROR: $?: $runScript"; exit 1; fi

echo ">>> Running Monitors ..."
  runScriptName="_run.monitors.sh"
  logFileName="$RUN_LOG_FILE_BASE.$runScriptName.log"
  runScript="$scriptDir/monitors/$runScriptName"
  nohup $runScript > $logFileName 2>&1 &
  pid="$!"; if wait $pid; then echo ">>> SUCCESS: $runScript"; else echo ">>> ERROR: $?: $runScript"; exit 1; fi

echo ">>> Stop Load ..."
  runScriptName="_stop.load.sh"
  logFileName="$RUN_LOG_FILE_BASE.$runScriptName.log"
  runScript="$scriptDir/load/$runScriptName"
  nohup $runScript > $logFileName 2>&1 &
  pid="$!"; if wait $pid; then echo ">>> SUCCESS: $runScript"; else echo ">>> ERROR: $?: $runScript"; exit 1; fi

echo ">>> Post-Run processing ..."
  runScriptName="_run.post-run.sh"
  logFileName="$RUN_LOG_FILE_BASE.$runScriptName.log"
  runScript="$scriptDir/$runScriptName"
  nohup $runScript > $logFileName 2>&1 &
  pid="$!"; if wait $pid; then echo ">>> SUCCESS: $runScript"; else echo ">>> ERROR: $?: $runScript"; exit 1; fi

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
