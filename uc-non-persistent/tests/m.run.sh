#!/usr/bin/env bash
# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# ---------------------------------------------------------------------------------------------

scriptDir=$(cd $(dirname "$0") && pwd);

export TEST_SPEC_FILE="$scriptDir/specs/.test/1_test.test.spec.yml"

export ANSIBLE_VERBOSITY=3

./_run.sh

###
# The End.
