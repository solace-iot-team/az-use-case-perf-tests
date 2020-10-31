#!/usr/bin/env bash
# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# ---------------------------------------------------------------------------------------------

scriptDir=$(cd $(dirname "$0") && pwd);
scriptName=$(basename $(test -L "$0" && readlink "$0" || echo "$0"));
projectHome=${scriptDir%/uc-non-persistent/*}
usecaseHome=$projectHome/uc-non-persistent

export TEST_SPEC_FILE="$scriptDir/1_auto.test.spec.yml"
export TEST_SPEC_INVENTORY_FILE="$TMP_DIR/test-specs/1_auto.test.spec.inventory.yml"

export TMP_DIR="$scriptDir/../tmp"
export SHARED_SETUP_DIR=$usecaseHome/shared-setup;

export ANSIBLE_VERBOSITY=0
nohup ../_abort.sh > ./logs/$scriptName.out 2>&1 &

# export ANSIBLE_VERBOSITY=3
# ../_abort.sh

###
# The End.
