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

  if [ -z "$TEST_SPEC_FILE" ]; then echo ">>> ERROR: missing env var:TEST_SPEC_FILE"; exit 1; fi

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

runScriptName="_generate.test.spec.inventory.sh"
  echo ">>> Run: $runScriptName"
  logFileName="$TMP_DIR/$runScriptName.log"
  runScript="$scriptDir/$runScriptName"
  nohup $runScript > $logFileName 2>&1 &
  pid="$!"; if wait $pid; then echo ">>> SUCCESS: $runScript"; else echo ">>> ERROR: $?: $runScript"; exit 1; fi


runScriptName="_run.test.spec.sh"
  echo ">>> Run: $runScriptName"
  logFileName="$TMP_DIR/$runScriptName.log"
  runScript="$scriptDir/$runScriptName"
  nohup $runScript > $logFileName 2>&1 &
  pid="$!"; if wait $pid; then echo ">>> SUCCESS: $runScript"; else echo ">>> ERROR: $?: $runScript"; exit 1; fi

###
# The End.
