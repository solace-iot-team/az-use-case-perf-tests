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

##############################################################################################################################
# Prepare
  export TMP_DIR=$scriptDir/tmp;
    mkdir $TMP_DIR > /dev/null 2>&1;
    rm -rf $TMP_DIR/*;
  export TEST_SPEC_DIR=$TMP_DIR/test-specs; mkdir $TEST_SPEC_DIR > /dev/null 2>&1;
  export SHARED_SETUP_DIR=$usecaseHome/shared-setup;

  testSpecJson=$(cat $TEST_SPEC_FILE | yq . )
  testSpecName=$(echo $testSpecJson | jq -r '.test_spec.name')
  export TEST_SPEC_INVENTORY_FILE="$TEST_SPEC_DIR/$testSpecName.test.spec.inventory.yml"

##############################################################################################################################
# Call scripts

if [ "$FAILED" -eq 0 ]; then
  runScriptName="_generate.test-spec.sh"
    echo ">>> Run: $runScriptName"
    logFileName="$TMP_DIR/$runScriptName.log"
    runScript="$scriptDir/$runScriptName"
    nohup $runScript > $logFileName 2>&1 &
    pid="$!"; if wait $pid; then echo ">>> SUCCESS: $runScript"; else echo ">>> ERROR: $?: $runScript"; FAILED=1; fi
fi

if [ "$FAILED" -eq 0 ]; then
  runScriptName="_run.test-spec.sh"
    echo ">>> Run: $runScriptName"
    logFileName="$TMP_DIR/$runScriptName.log"
    runScript="$scriptDir/$runScriptName"
    nohup $runScript > $logFileName 2>&1 &
    pid="$!"; if wait $pid; then echo ">>> SUCCESS: $runScript"; else echo ">>> ERROR: $?: $runScript"; FAILED=1; fi
fi

##############################################################################################################################
# Workflow output

  if [ "$FAILED" -gt 0 ]; then
    echo ">>> FINISHED:FAILED - $scriptName";
    exit 1
  else
    echo ">>> FINISHED:SUCCESS - $scriptName";
  fi

###
# The End.
