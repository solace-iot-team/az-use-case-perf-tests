#!/usr/bin/env bash
# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# ---------------------------------------------------------------------------------------------

scriptDir=$(cd $(dirname "$0") && pwd);
scriptName=$(basename $(test -L "$0" && readlink "$0" || echo "$0"));
projectHome=${scriptDir%/analytics/*}

# settings

# export NOTEBOOK_NAME="run-analysis.ipynb"
# export NOTEBOOK_FILE="$projectHome/uc-non-persistent/analytics/notebooks/$NOTEBOOK_NAME"

export NOTEBOOK_NAME="devel-1.ipynb"
export NOTEBOOK_FILE="$scriptDir/$NOTEBOOK_NAME"

export TEST_RESULTS_DIR="$projectHome/uc-non-persistent/test-results/stats"

export ANALYSIS_OUT_DIR="$projectHome/uc-non-persistent/test-results/analysis"

infrastructureIds=(
  "aws.devel1-standalone"
  # "azure.devel1"
  # "azure.devel2"
)

export INFRASTRUCTURE_IDS="${infrastructureIds[*]}"

export LOG_DIR="$scriptDir/logs"

rm -rf $LOG_DIR/*

nohup ../_run.all.sh > ./logs/$scriptName.out 2>&1 &

###
# The End.
