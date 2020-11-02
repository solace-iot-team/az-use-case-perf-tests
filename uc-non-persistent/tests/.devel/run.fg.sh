#!/usr/bin/env bash
# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# ---------------------------------------------------------------------------------------------

scriptDir=$(cd $(dirname "$0") && pwd);
scriptName=$(basename $(test -L "$0" && readlink "$0" || echo "$0"));
projectHome=${scriptDir%/uc-non-persistent/*}
usecaseHome=$projectHome/uc-non-persistent

export TEST_SPEC_FILE="$scriptDir/devel.test.spec.yml"
export TEST_SPEC_FILE="$scriptDir/devel2.test.spec.yml"

export ANSIBLE_VERBOSITY=3

# ../_run.sh > ./logs/$scriptName.out 2>&1

../_run.sh

###
# The End.
