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

export TEST_RESULTS_DIR="$projectHome/uc-non-persistent/test-results/stats"

export ANALYSIS_OUT_DIR="$projectHome/uc-non-persistent/test-results/analysis"

infrastructureIds=(
  "azure.tp-003-standalone"
  "aws.tp-003-standalone"
)

export INFRASTRUCTURE_IDS="${infrastructureIds[*]}"

export LOG_DIR="$scriptDir/logs"

export NOTEBOOK_FILE="$projectHome/analytics/notebooks/$NOTEBOOK_NAME"

rm -rf $LOG_DIR/*


../_run.all.sh

# ../_run.sh > ./logs/$scriptName.out 2>&1
# nohup ../_run.sh > ./logs/$scriptName.out 2>&1 &

###
# The End.
