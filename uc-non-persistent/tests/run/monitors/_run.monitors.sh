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
# Arguments & Environment Variables

  # if set:
  # - doesn't wait for user input
  # - post processes results
  auto=$1

  if [ -z "$UC_NON_PERSISTENT_INFRASTRUCTURE" ]; then echo ">>> ERROR: missing env var: UC_NON_PERSISTENT_INFRASTRUCTURE"; exit 1; fi
  if [ -z "$RUN_SPEC_FILE" ]; then echo ">>> ERROR: missing env var: RUN_SPEC_FILE"; exit 1; fi
  if [ -z "$SHARED_SETUP_DIR" ]; then echo ">>> ERROR: missing env var: SHARED_SETUP_DIR"; exit 1; fi
  if [ -z "$RUN_LOG_FILE_BASE" ]; then echo ">>> ERROR: missing env var:RUN_LOG_FILE_BASE"; exit 1; fi
  if [ -z "$RUN_LOG_DIR" ]; then export RUN_LOG_DIR=$scriptDir/tmp; mkdir $RUN_LOG_DIR > /dev/null 2>&1; fi
  if [ -z "$RUN_ID" ]; then export RUN_ID=$(date -u +"%Y-%m-%d-%H-%M-%S"); fi

############################################################################################################################
# Set monitor scripts
  if [ "$IS_RUN_MONITOR_VPN_STATS" ]; then runMonitorScript_VpnStats="_run.monitor.vpn-stats.sh"; fi
  if [ "$IS_RUN_MONITOR_LATENCY" ]; then runMonitorScript_Latency="_run.monitor.latency.sh"; fi
  if [ "$IS_RUN_MONITOR_BROKERNODE_LATENCY" ]; then runMonitorScript_BrokerNodeLatency="_run.monitor.brokernode.latency.sh"; fi
  if [ "$IS_RUN_MONITOR_PING" ]; then runMonitorScript_Ping="_run.monitor.ping.sh"; fi
  monitorScripts=(
    "$runMonitorScript_VpnStats"
    "$runMonitorScript_Latency"
    "$runMonitorScript_BrokerNodeLatency"
    "$runMonitorScript_Ping"
  )

############################################################################################################################
# Check if any monitors running

##############################################################################################################################
# Prepare
resultDirBase="$usecaseHome/test-results/stats/$UC_NON_PERSISTENT_INFRASTRUCTURE"
resultDir="$resultDirBase/run.current"
resultDirLatest="$resultDirBase/run.latest"
# Set for all monitors
export runStartTsEpochSecs=$(date -u +%s)

if [ -z "$auto" ]; then rm -f $RUN_LOG_DIR/*.log; fi

mkdir $resultDirBase > /dev/null 2>&1
mkdir $resultDir > /dev/null 2>&1
rm -f $resultDir/*

echo;
echo "##############################################################################################################"
echo "# Starting Monitors"
echo ">>> infrastructure   : $UC_NON_PERSISTENT_INFRASTRUCTURE"
echo ">>> utc start time   : "$(date -u +"%Y-%m-%d %H:%M:%S")""
echo ">>> local start time : "$(date +"%Y-%m-%d %H:%M:%S")""
echo
if [ -z "$auto" ]; then x=$(wait4Key); fi

##############################################################################################################################
# Call monitor scripts
monitorScriptPids=""
for monitorScript in ${monitorScripts[@]}; do
  echo ">>> Start $monitorScript ..."
  logFileName="$RUN_LOG_FILE_BASE.$monitorScript.log"
  nohup $scriptDir/$monitorScript > $logFileName  2>&1 &
  monitorScriptPids+=" $!"
done

# echo "##############################################################################################################"
echo ">>> Waiting for Processes to finish:"
sleep 1
for pid in $monitorScriptPids; do
  # ps -ef $pid doesn't work on ubuntu
  ps $pid || true
done

##############################################################################################################################
# monitor if 1 has failed
FAILED=0
while true; do
  wait -n || {
    code="$?"
    if [ $code = "127" ]; then
      # 127:
      # last background job has exited successfully
      # or: command was not found
      echo ">>> SUCCESS: all monitors finished successfully"
      FAILED=0
    else
      echo ">>> ERROR: 1 or more monitors failed with code=$code"
      FAILED=1
    fi
    break
  }
done;

killCount=0
if [ "$FAILED" -gt 0 ]; then
  echo ">>> ERROR: at least one monitor failed. terminating all other monitors";
  for pid in $monitorScriptPids; do
    echo ">>> DEBUG: children of pid=$pid"
    _pidList=$(getChildrenPids $pid)
    echo ">>> DEBUG: _pidList='"$_pidList"'"
    if [[ ! -z "$_pidList" ]]; then
      for _pid in $_pidList; do
        echo ">>> DEBUG: kill -SIGKILL $_pid"
        ((killCount=killCount+1))
        kill -SIGKILL $_pid > /dev/null 2>&1 || true
      done
    fi
  done
fi

##############################################################################################################################
# finished
echo ">>> utc end time   : "$(date -u +"%Y-%m-%d %H:%M:%S")""
echo ">>> local end time : "$(date +"%Y-%m-%d %H:%M:%S")""

##############################################################################################################################
# Post Processing of Results
if [ -z "$auto" ]; then
  echo ">>> Post processing results"
    runScriptName="post-process-results.sh"
    runScript="$scriptDir/../lib/$runScriptName"
    logFileName="$RUN_LOG_FILE_BASE.$runScriptName.log"
    nohup $runScript > $logFileName 2>&1 &
    pid="$!"; if wait $pid; then echo; else echo ">>> ERROR: $runScript"; exit 1; fi
fi

##############################################################################################################################
# final output
if [ "$FAILED" -gt 0 ]; then
  echo ">>> ERROR: running monitors. see log files for details";
  ls -la $RUN_LOG_FILE_BASE*.log
  exit 1
else
  echo ">>> SUCCESS: $scriptName"
fi

###
# The End.
