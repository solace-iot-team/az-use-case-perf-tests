#!/usr/bin/env bash
# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# ---------------------------------------------------------------------------------------------

############################################################################################################################
# Check env vars

  if [ -z "$UC_NON_PERSISTENT_INFRASTRUCTURE" ]; then echo ">>> ERROR: missing env var 'UC_NON_PERSISTENT_INFRASTRUCTURE'"; exit 1; fi
  if [ -z "$RUN_LOG_DIR" ]; then echo ">>> ERROR: missing env var 'RUN_LOG_DIR'"; exit 1; fi
  if [ -z "$RUN_ID" ]; then echo ">>> ERROR: missing env var 'RUN_ID'"; exit 1; fi

##############################################################################################################################
# Prepare
scriptDir=$(cd $(dirname "$0") && pwd);
scriptName=$(basename $(test -L "$0" && readlink "$0" || echo "$0"));
projectHome=${scriptDir%/ansible/*}
source $projectHome/ansible/.lib/functions.sh

##############################################################################################################################
# Check for errors in the logs
errors=$(grep -n -e "ERROR" -e "Killed" $RUN_LOG_DIR/*.log)
if [ -z "$errors" ]; then
  echo ">>> SUCCESS: found no errors in log files"
  touch $RUN_LOG_DIR/SUCCESS.log
else
  echo ">>> ERROR: found errors in log files"
  touch $RUN_LOG_DIR/ERROR.log
  errCount=0
  while IFS= read line; do
    ((errCount++))
    echo $line >> $RUN_LOG_DIR/ERROR.log
  done < <(printf '%s\n' "$errors")
fi

##############################################################################################################################
# Post Processing of Results
cloudProvider=${UC_NON_PERSISTENT_INFRASTRUCTURE%%.*}
resultDirBase="$projectHome/test-results/stats/$UC_NON_PERSISTENT_INFRASTRUCTURE"
resultDir="$resultDirBase/run.current"
resultDirLatest="$resultDirBase/run.latest"

echo ">>> copy docker compose deployed template to result dir"
cp $projectHome/ansible/docker-image/*.deployed.yml "$resultDir/PubSub.docker-compose.$RUN_ID.yml"
if [[ $? != 0 ]]; then echo ">>> ERROR copy docker compose template to result dir"; echo; exit 1; fi

echo ">>> copy all log files to result dir"
mkdir $resultDir/logs > /dev/null 2>&1
cp $RUN_LOG_DIR/*.log "$resultDir/logs"
if [[ $? != 0 ]]; then echo ">>> ERROR copy log files to result dir"; echo; exit 1; fi

echo ">>> move result dir to run id"
finalResultDir="$resultDirBase/run.$RUN_ID"
mv $resultDir $finalResultDir
if [[ $? != 0 ]]; then echo ">>> ERROR moving resultDir=$resultDir."; echo; exit 1; fi
cd $resultDirBase
rm -f $resultDirLatest
ln -s $finalResultDir $resultDirLatest
cd $scriptDir

###
# The End.
