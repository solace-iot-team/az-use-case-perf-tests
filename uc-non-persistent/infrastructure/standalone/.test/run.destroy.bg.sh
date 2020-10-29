#!/usr/bin/env bash
# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# ---------------------------------------------------------------------------------------------

scriptDir=$(cd $(dirname "$0") && pwd);
scriptName=$(basename $(test -L "$0" && readlink "$0" || echo "$0"));


#  format: {cloud_provider}.{config}
export infrastructureIds=(
  "azure.test1"
  "azure.test2"
  "aws.test1"
)


export INFRASTRUCTURE_IDS="${infrastructureIds[*]}"

export LOG_DIR=$scriptDir/logs
rm -f $LOG_DIR/**destroy**

export TF_VARIABLES_DIR=$scriptDir

nohup ../_run.destroy-all.sh > $LOG_DIR/$scriptName.out 2>&1 &

###
# The End.
