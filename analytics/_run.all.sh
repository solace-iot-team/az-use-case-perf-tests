#!/usr/bin/env bash
# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# ---------------------------------------------------------------------------------------------

##############################################################################################################################
# Prepare
scriptDir=$(cd $(dirname "$0") && pwd);
scriptName=$(basename $(test -L "$0" && readlink "$0" || echo "$0"));
projectHome=${scriptDir%/analytics}
source $projectHome/.lib/functions.sh

FAILED=0

############################################################################################################################
# Environment Variables

  if [ -z "$NOTEBOOK_NAME" ]; then echo ">>> ERROR: - $scriptName - missing env var:NOTEBOOK_NAME"; FAILED=1; fi
  if [ -z "$TEST_RESULTS_DIR" ]; then echo ">>> ERROR: - $scriptName - missing env var:TEST_RESULTS_DIR"; FAILED=1; fi
  if [ -z "$ANALYSIS_OUT_DIR" ]; then echo ">>> ERROR: - $scriptName - missing env var:ANALYSIS_OUT_DIR"; FAILED=1; fi
  if [ -z "$LOG_DIR" ]; then echo ">>> ERROR: - $scriptName - missing env var:LOG_DIR"; FAILED=1; fi
  if [ -z "$INFRASTRUCTURE_IDS" ]; then echo ">>> ERROR: - $scriptName - missing env var:INFRASTRUCTURE_IDS"; FAILED=1; fi


##############################################################################################################################
# Checks & Prepare

  if [ ! -d "$TEST_RESULTS_DIR" ]; then echo ">>> ERROR: - $scriptName - test results dir does not exist: $TEST_RESULTS_DIR"; FAILED=1; fi
  if [ ! -d "$LOG_DIR" ]; then echo ">>> ERROR: - $scriptName - log dir does not exist: $LOG_DIR"; FAILED=1; fi

  notebookFile="$scriptDir/notebooks/$NOTEBOOK_NAME"
  if [ ! -f "$notebookFile" ]; then echo ">>> ERROR: - $scriptName - notebook does not not exist: $notebookFile"; FAILED=1; fi

  for infrastructureId in ${INFRASTRUCTURE_IDS[@]}; do
    if [ ! -d "$TEST_RESULTS_DIR/$infrastructureId" ]; then echo ">>> ERROR: - $scriptName - infrastructure result directory does not exist: '$TEST_RESULTS_DIR/$infrastructureId'"; FAILED=1; fi
  done

##############################################################################################################################
# Run

if [ "$FAILED" -eq 0 ]; then

  mkdir -p $ANALYSIS_OUT_DIR
  rm -rf $ANALYSIS_OUT_DIR/*

  for infrastructureId in ${INFRASTRUCTURE_IDS[@]}; do
    # read all the run ids
    runsDir="$TEST_RESULTS_DIR/$infrastructureId"
    cd $runsDir
    for runDir in *; do
      if [ -d "$runDir" ]; then

        runNotebookName=$NOTEBOOK_NAME

        echo ">>> Analyzing: $runNotebookName($infrastructureId/$runDir)"
        # env vars for notebook
        export ANALYTICS_ENABLE_LOGGING="true"
        export ANALYTICS_LOG_FILE="$LOG_DIR/$runNotebookName.$infrastructureId.$runDir.log"
        export NOTEBOOK_RESULTS_LOCATION_DIR="$runsDir"
        # extract id only
        export NOTEBOOK_RUN_ID=${runDir#run.}
        export NOTEBOOK_RUN_PRODUCTION_MODE="true"

        logFileName="$LOG_DIR/nbconvert.$runNotebookName.$infrastructureId.$runDir.log"
        analysisOutputFileName="$ANALYSIS_OUT_DIR/$runNotebookName.$infrastructureId.$runDir.html"
        # do not run all in parallel - could cause mem issues
        jupyter nbconvert --execute $notebookFile --no-input --stdout --to html 2> $logFileName 1> $analysisOutputFileName
        code=$?; if [[ $code != 0 ]]; then echo ">>> ERROR - $code - notebook exit: $runNotebookName"; FAILED=1; fi

# DEBUG: for testing only
break

      fi
      if [ "$FAILED" -gt 0 ]; then break; fi
    done
    cd $scriptDir
    if [ "$FAILED" -gt 0 ]; then break; fi
  done
fi
##############################################################################################################################
# Check Results

  logFilePattern="$LOG_DIR/*"
  logErrors=$(grep -n -e "ERROR" -e "Traceback" $logFilePattern )

  outputFilePattern="$ANALYSIS_OUT_DIR/*"
  # TODO: find the correct patterns
  outputErrors=$(grep -n -e "NameError" -e "Error" $outputFilePattern )

  if [[ -z "$logErrors" && -z "$outputErrors" && "$FAILED" -eq 0 ]]; then
    echo ">>> FINISHED:SUCCESS - $scriptName";
    touch "$LOG_DIR/$scriptName.SUCCESS.out"
  else
    echo ">>> FINISHED:FAILED - $scriptName";

    while IFS= read line; do
      echo $line >> "$LOG_DIR/$scriptName.ERROR.out"
    done < <(printf '%s\n' "$logErrors")

    while IFS= read line; do
      echo $line >> "$LOG_DIR/$scriptName.ERROR.out"
    done < <(printf '%s\n' "$outputErrors")

    exit 1
  fi

###
# The End.
