#!/usr/bin/env bash
# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# ---------------------------------------------------------------------------------------------

##############################################################################################################################
# Prepare
scriptDir=$(cd $(dirname "$0") && pwd);
scriptName=$(basename $(test -L "$0" && readlink "$0" || echo "$0"));
projectHome=${scriptDir%/uc-non-persistent/*}
usecaseHome=$projectHome/uc-non-persistent
source $projectHome/.lib/functions.sh

############################################################################################################################
# Check env vars

  if [ -z "$UC_NON_PERSISTENT_INFRASTRUCTURE" ]; then echo ">>> ERROR: missing env var 'UC_NON_PERSISTENT_INFRASTRUCTURE'"; exit 1; fi
  if [ -z "$RUN_ID" ]; then echo ">>> ERROR: missing env var 'RUN_ID'"; exit 1; fi
  if [ -z "$RUN_LOG_FILE_BASE" ]; then echo ">>> ERROR: missing env var:'RUN_LOG_FILE_BASE'"; exit 1; fi
  if [ -z "$LOG_DIR" ]; then echo ">>> ERROR: missing env var:'LOG_DIR'"; exit 1; fi

##############################################################################################################################
# Check for errors in the logs
errors=$(grep -n -e "ERROR" -e "Killed" $RUN_LOG_FILE_BASE*.log)
if [ -z "$errors" ]; then
  echo ">>> SUCCESS: found no errors in log files"
  touch $RUN_LOG_FILE_BASE.SUCCESS.log
else
  echo ">>> ERROR: found errors in log files"
  touch $RUN_LOG_FILE_BASE.ERROR.log
  errCount=0
  while IFS= read line; do
    ((errCount++))
    echo $line >> $RUN_LOG_FILE_BASE.ERROR.log
  done < <(printf '%s\n' "$errors")
fi

##############################################################################################################################
# Post Processing of Results
cloudProvider=${UC_NON_PERSISTENT_INFRASTRUCTURE%%.*}
resultDirBase="$usecaseHome/test-results/stats/$UC_NON_PERSISTENT_INFRASTRUCTURE"
resultDir="$resultDirBase/run.current"
# resultDirLatest="$resultDirBase/run.latest"

mkdir $resultDir > /dev/null 2>&1

FAILED=0

echo ">>> copy docker compose deployed template to result dir"
# NOTE: this should be in shared-setup under the infrastructure id
cp $usecaseHome/infrastructure/standalone/.deployed/*.deployed.yml "$resultDir/PubSub.docker-compose.$RUN_ID.yml"
# do not exit, we still need the log files
if [[ $? != 0 ]]; then echo ">>> ERROR - $scriptName - copy docker compose template to result dir"; FAILED=1; fi

echo ">>> copy all log files to result dir"
mkdir $resultDir/logs > /dev/null 2>&1
cp $RUN_LOG_FILE_BASE*.log "$resultDir/logs"
# do not exit, we still need the log files
if [[ $? != 0 ]]; then echo ">>> ERROR - $scriptName - copy log files to result dir"; FAILED=1; fi
cp $LOG_DIR/ABORT.log "$resultDir/logs" > /dev/null 2>&1

echo ">>> move result dir to run id"
finalResultDir="$resultDirBase/run.$RUN_ID"
mv $resultDir $finalResultDir
if [[ $? != 0 ]]; then echo ">>> ERROR - $scriptName - moving resultDir=$resultDir."; FAILED=1; fi

if [ "$FAILED" -gt 0 ]; then
  echo ">>> ERROR - $scriptName - FAILED"
  exit 1
fi

###
# The End.
