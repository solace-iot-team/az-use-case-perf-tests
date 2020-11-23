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


  if [ -z "$TMP_DIR" ]; then echo ">>> ERROR: missing env var:TMP_DIR"; exit 1; fi
  if [ -z "$TEST_SPEC_FILE" ]; then echo ">>> ERROR: missing env var:TEST_SPEC_FILE"; exit 1; fi
    x=$(assertFile "$TEST_SPEC_FILE") || exit
  if [ -z "$TEST_SPEC_DIR" ]; then echo ">>> ERROR: missing env var:TEST_SPEC_DIR"; exit 1; fi
  if [ -z "$SHARED_SETUP_DIR" ]; then echo ">>> ERROR: missing env var:SHARED_SETUP_DIR"; exit 1; fi
  if [ -z "$VALIDATE_SPECS" ]; then VALIDATE_SPECS="False"; fi

############################################################################################################################
# Validate the test spec

if [[ "$VALIDATE_SPECS" == "True" ]]; then

  if [ -z "$SCHEMAS_DIR" ]; then echo ">>> ERROR: missing env var:SCHEMAS_DIR"; exit 1; fi

  testSpecSchemaFile="$SCHEMAS_DIR/schema.test.spec.json"

  testSpecJson=$(cat $TEST_SPEC_FILE | yq . )
  code=$?; if [[ $code != 0 ]]; then echo ">>> ERROR - code=$code - 'yq' reading test spec=$TEST_SPEC_FILE - $scriptName"; exit 1; fi

  testSpecName=$(echo $testSpecJson | jq -r '.test_spec.name' )
  if [ -z "$testSpecName" ]; then echo ">>> ERROR: missing test_spec.name in test spec: $TEST_SPEC_FILE - $scriptName"; exit 1; fi

  testSpecJsonFile="$TEST_SPEC_DIR/$testSpecName.test.spec.json"
  rm -f $testSpecJsonFile
  echo $testSpecJson | jq . > $testSpecJsonFile

  jsonschema --instance $testSpecJsonFile $testSpecSchemaFile
  code=$?; if [[ $code != 0 ]]; then echo ">>> ERROR - code=$code - jsonschema: test spec=$TEST_SPEC_FILE: $scriptName"; exit 1; fi
fi

exit

############################################################################################################################
# Generate Run Specs

  playbook="$scriptDir/playbooks/generate.test-spec.playbook.yml"
  ansible-playbook \
                  $playbook \
                  --extra-vars "TEST_SPEC_FILE=$TEST_SPEC_FILE" \
                  --extra-vars "TEST_SPEC_DIR=$TEST_SPEC_DIR" \
                  --extra-vars "SHARED_SETUP_DIR=$SHARED_SETUP_DIR" \
                  --extra-vars "VALIDATE_SPECS=$VALIDATE_SPECS"

  code=$?; if [[ $code != 0 ]]; then echo ">>> ERROR - $code - playbook exit: $scriptName"; echo; exit 1; fi

###
# The End.
