#!/usr/bin/env bash
# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# ---------------------------------------------------------------------------------------------

scriptDir=$(cd $(dirname "$0") && pwd);
scriptName=$(basename $(test -L "$0" && readlink "$0" || echo "$0"));
projectHome=${scriptDir%/uc-non-persistent/*}
usecaseHome=$projectHome/uc-non-persistent


export UC_NON_PERSISTENT_INFRASTRUCTURE="aws.devel1-standalone"
runName="testing_load_startup"
runName="test_vpn_stats_client_connections"
runName="test_p2p_1_to_40_100_bytes"

export ANSIBLE_VERBOSITY=3

export RUN_SPEC_FILE="$usecaseHome/tests/tmp/run-specs/$UC_NON_PERSISTENT_INFRASTRUCTURE.$runName.yml"
export SHARED_SETUP_DIR="$usecaseHome/shared-setup"
export RUN_LOG_FILE_BASE="$usecaseHome/tests/tmp/$UC_NON_PERSISTENT_INFRASTRUCTURE.$runName"
export IS_RUN_LOAD="true"

../_start.load.sh

###
# The End.
