#!/usr/bin/env bash
# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# ---------------------------------------------------------------------------------------------

scriptDir=$(cd $(dirname "$0") && pwd);
scriptName=$(basename $(test -L "$0" && readlink "$0" || echo "$0"));
projectHome=${scriptDir%/uc-non-persistent/*}
usecaseHome=$projectHome/uc-non-persistent


export UC_NON_PERSISTENT_INFRASTRUCTURE="azure.devel1-standalone"
runName="testing_load_startup"

export ANSIBLE_VERBOSITY=3

export SHARED_SETUP_DIR="$usecaseHome/shared-setup"
export RUN_LOG_FILE_BASE="$usecaseHome/tests/tmp/$UC_NON_PERSISTENT_INFRASTRUCTURE.$runName"


../_stop.load.sh

###
# The End.
