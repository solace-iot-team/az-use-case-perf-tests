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

FAILED=0

############################################################################################################################
# Environment Variables

  if [ -z "$TEST_SPEC_FILE" ]; then echo ">>> ERROR: - $scriptName - missing env var:TEST_SPEC_FILE"; FAILED=1; fi
  if [ -z "$LOG_DIR" ]; then echo ">>> ERROR: - $scriptName - missing env var:LOG_DIR"; FAILED=1; fi
  if [ -z "$ANSIBLE_PYTHON_INTERPRETER" ]; then echo ">>> ERROR: - $scriptName - missing env var:ANSIBLE_PYTHON_INTERPRETER"; FAILED=1; fi
  if [ -z "$VALIDATE_SPECS" ]; then VALIDATE_SPECS="False"; fi

##############################################################################################################################
# Prepare
  rm -rf $LOG_DIR/*
  export TMP_DIR=$LOG_DIR/tmp;
    mkdir $TMP_DIR > /dev/null 2>&1;
    rm -rf $TMP_DIR/*;
  export TEST_SPEC_DIR=$TMP_DIR/test-specs; mkdir $TEST_SPEC_DIR > /dev/null 2>&1;
  export SHARED_SETUP_DIR=$usecaseHome/shared-setup;

  testSpecJson=$(cat $TEST_SPEC_FILE | yq . )
  testSpecName=$(echo $testSpecJson | jq -r '.test_spec.name')
  export TEST_SPEC_INVENTORY_FILE="$TEST_SPEC_DIR/$testSpecName.test.spec.inventory.yml"

##############################################################################################################################
# start local web server for schemas
if [[ "$VALIDATE_SPECS" == "True" ]]; then

  export SCHEMAS_DIR="$scriptDir/tp-schemas"

  currDir=$(pwd)
  cd $SCHEMAS_DIR
  nohup $ANSIBLE_PYTHON_INTERPRETER -m http.server 8811 > $LOG_DIR/schema.http.server.out 2>&1 &
  httpServerPid="$!"
  cd $currDir
fi

##############################################################################################################################
# Call scripts

if [ "$FAILED" -eq 0 ]; then
  runScriptName="_generate.test-spec.sh"
    echo ">>> Run: $runScriptName"
    logFileName="$LOG_DIR/$runScriptName.out"
    runScript="$scriptDir/$runScriptName"
    nohup $runScript > $logFileName 2>&1 &
    pid="$!"; if wait $pid; then echo ">>> SUCCESS: $runScript"; else echo ">>> ERROR: $?: $runScript"; FAILED=1; fi
fi

if [ "$FAILED" -eq 0 ]; then
  runScriptName="_run.test-spec.sh"
    echo ">>> Run: $runScriptName"
    logFileName="$LOG_DIR/$runScriptName.out"
    runScript="$scriptDir/$runScriptName"
    nohup $runScript > $logFileName 2>&1 &
    pid="$!"; if wait $pid; then echo ">>> SUCCESS: $runScript"; else echo ">>> ERROR: $?: $runScript"; FAILED=1; fi
fi

##############################################################################################################################
# stop local web server for schemas
if [[ "$VALIDATE_SPECS" == "True" ]]; then

  kill $httpServerPid

fi

##############################################################################################################################
# Workflow output

if [ "$FAILED" -gt 0 ]; then
  touch "$LOG_DIR/$scriptName.ERROR.log"
  # Check for errors in the logs
  errors=$(grep -n -e "ERROR" -e "FAILED" -e "Traceback" -e "404" $LOG_DIR/*.out)
  if [ -z "$errors" ]; then
    echo ">>> ERROR: found no errors in log files, but should have"
  else
    echo ">>> ERROR: found errors in log files"
    errCount=0
    while IFS= read line; do
      ((errCount++))
      echo $line >> "$LOG_DIR/$scriptName.ERROR.log"
    done < <(printf '%s\n' "$errors")
  fi
  echo ">>> FINISHED:FAILED - $scriptName";
  exit 1
else
  echo ">>> FINISHED:SUCCESS - $scriptName";
  touch "$LOG_DIR/$scriptName.SUCCESS.log"
fi

###
# The End.
