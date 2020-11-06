#!/usr/bin/env bash
# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# ---------------------------------------------------------------------------------------------

scriptDir=$(cd $(dirname "$0") && pwd);
scriptName=$(basename $(test -L "$0" && readlink "$0" || echo "$0"));
projectHome=${scriptDir%/analytics/*}

# settings

export NOTEBOOK_NAME="run-analysis.ipynb"
export NOTEBOOK_FILE="$projectHome/uc-non-persistent/analytics/notebooks/$NOTEBOOK_NAME"

export TEST_RESULTS_DIR="$projectHome/uc-non-persistent/test-results/stats"

export ANALYSIS_OUT_DIR="$projectHome/uc-non-persistent/test-results/analysis"

#  format: {cloud_provider}.{config}
export infrastructureIds=(
  "azure.test1"
  # "azure.test2"
  "aws.test1"
)

export INFRASTRUCTURE_IDS="${infrastructureIds[*]}"

export LOG_DIR="$scriptDir/logs"

rm -rf $LOG_DIR/*

../_run.all.sh > ./logs/$scriptName.out 2>&1


###
# The End.
