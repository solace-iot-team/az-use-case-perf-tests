#!/usr/bin/env bash
# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# ---------------------------------------------------------------------------------------------

scriptDir=$(cd $(dirname "$0") && pwd);
scriptName=$(basename $(test -L "$0" && readlink "$0" || echo "$0"));


#  format: {cloud_provider}.{config}
export infrastructureIds=(
  "azure.devel1-standalone"
  # "azure.devel2-standalone"
)


export INFRASTRUCTURE_IDS="${infrastructureIds[*]}"

export LOG_DIR=$scriptDir/logs
rm -f $LOG_DIR/*

# ../_run.delete-all.sh > $LOG_DIR/$scriptName.out 2>&1

../_run.delete-all.sh


###
# The End.
