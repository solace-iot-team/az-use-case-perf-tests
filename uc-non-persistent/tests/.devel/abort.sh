#!/usr/bin/env bash
# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# ---------------------------------------------------------------------------------------------

scriptDir=$(cd $(dirname "$0") && pwd);
scriptName=$(basename $(test -L "$0" && readlink "$0" || echo "$0"));
projectHome=${scriptDir%/uc-non-persistent/*}
usecaseHome=$projectHome/uc-non-persistent

export TMP_DIR="$scriptDir/../tmp"
export TEST_SPEC_FILE="$scriptDir/devel1.test.spec.yml"
export TEST_SPEC_INVENTORY_FILE="$TMP_DIR/test-specs/devel1.test.spec.inventory.yml"

export SHARED_SETUP_DIR=$usecaseHome/shared-setup;

# export ANSIBLE_VERBOSITY=0
# nohup ../_abort.sh > ./logs/$scriptName.out 2>&1 &
export ANSIBLE_VERBOSITY=3
../_abort.sh

###
# The End.
