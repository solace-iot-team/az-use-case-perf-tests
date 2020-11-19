#!/usr/bin/env bash
# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# ---------------------------------------------------------------------------------------------

scriptDir=$(cd $(dirname "$0") && pwd);
scriptName=$(basename $(test -L "$0" && readlink "$0" || echo "$0"));

export UC_NON_PERSISTENT_INFRASTRUCTURE="aws.devel1-standalone"
# export UC_NON_PERSISTENT_INFRASTRUCTURE="azure.devel1-standalone"

export ANSIBLE_VERBOSITY=3
export LOG_DIR=$scriptDir/logs
rm -f $LOG_DIR/*

../_run.bootstrap.sh $UC_NON_PERSISTENT_INFRASTRUCTURE

###
# The End.
