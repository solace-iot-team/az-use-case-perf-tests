#!/usr/bin/env bash
# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# ---------------------------------------------------------------------------------------------

scriptDir=$(cd $(dirname "$0") && pwd);
projectHome=${scriptDir%/uc-non-persistent/*}
usecaseHome=$projectHome/uc-non-persistent


export TEST_SPEC_FILE="$scriptDir/../specs/.test/1_test.test.spec.yml"


export TEST_SPEC_DIR=$TMP_DIR/test-specs
export SHARED_SETUP_DIR=$usecaseHome/shared-setup;
export ANSIBLE_VERBOSITY=3


../_generate.test-spec.sh


testSpecJson=$(cat $TEST_SPEC_FILE | yq . )
testSpecName=$(echo $testSpecJson | jq -r '.test_spec.name')
export TEST_SPEC_INVENTORY_FILE="$TEST_SPEC_DIR/$testSpecName.test.spec.inventory.yml"
export GENERATE_ONLY="True"

../_run.test-spec.sh

###
# The End.
