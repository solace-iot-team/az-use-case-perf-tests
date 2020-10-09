#!/usr/bin/env bash
# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# ---------------------------------------------------------------------------------------------

scriptDir=$(cd $(dirname "$0") && pwd);
scriptName=$(basename $(test -L "$0" && readlink "$0" || echo "$0"));

if [ -z "$ANSIBLE_VERBOSITY" ]; then export ANSIBLE_VERBOSITY=0; fi
export RUN_LOG_DIR=$scriptDir/tmp; mkdir $RUN_LOG_DIR > /dev/null 2>&1;

callScript=_run.tests.sh
logFile="$RUN_LOG_DIR/$callScript.log"

# check if there is a .run.tests.sh already running ==> no start
runningPids=( $(ps -ef|grep $callScript | awk '{ print $2 }') )
let countPids=${#runningPids[@]}
if [ "$countPids" -gt 1 ]; then
  echo ">>> ERROR: found already running $callScript, exiting"; exit 1
fi

rm -f $RUN_LOG_DIR/*;

nohup $scriptDir/$callScript > $logFile $* 2>&1 &

echo "###########################################################################################"
echo ">>> log: $logFile"
echo

###
# The End.
