#!/usr/bin/env bash
# echo $BASH_VERSION
# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# ---------------------------------------------------------------------------------------------

##############################################################################################################################
# Prepare
scriptDir=$(cd $(dirname "$0") && pwd);
source $scriptDir/../../.lib/functions.sh
scriptName=$(basename $(test -L "$0" && readlink "$0" || echo "$0"));
projectHome=${scriptDir%/ansible/*}
sharedSetupDir="$projectHome/shared-setup"; [ ! -d $sharedSetupDir ] && (echo ">>> ERROR: directory $sharedSetupDir DOES NOT exists."; exit)
monitorVarsFile=$(assertFile "$scriptDir/../../vars/monitor.vars.yml") || exit

############################################################################################################################
# Environment Variables

  # is set, doesn't wait for user input
  auto=$2

    if [ -z "$1" ]; then
      if [ -z "$UC_NON_PERSISTENT_INFRASTRUCTURE" ]; then
          echo ">>> ERROR: missing infrastructure info. pass either as env-var: UC_NON_PERSISTENT_INFRASTRUCTURE or as argument"
          echo "    for example: $scriptName azure.infra1-standalone"
          echo; exit 1
      fi
    else
      export UC_NON_PERSISTENT_INFRASTRUCTURE=$1
    fi

    if [ -z "$RUN_LOG_DIR" ]; then export RUN_LOG_DIR=$scriptDir/tmp; mkdir $RUN_LOG_DIR > /dev/null 2>&1; fi
    if [ -z "$RUN_ID" ]; then export RUN_ID=$(date -u +"%Y-%m-%d-%H-%M-%S"); fi

############################################################################################################################
# Set monitor scripts
monitorScripts=(
  "run.monitor.vpn-stats.sh"
  "run.monitor.latency.sh"
  "run.monitor.brokernode.latency.sh"
  "run.monitor.ping.sh"
)

############################################################################################################################
# Check if any monitors running

##############################################################################################################################
# Prepare
cloudProvider=${UC_NON_PERSISTENT_INFRASTRUCTURE%%.*}
resultDirBase="$projectHome/test-results/stats/$UC_NON_PERSISTENT_INFRASTRUCTURE"
resultDir="$resultDirBase/run.current"
resultDirLatest="$resultDirBase/run.latest"
# Set for all monitors
export runStartTsEpochSecs=$(date -u +%s)

totalNumSamplesStr=$(cat $monitorVarsFile | yq '.general.total_num_samples') || exit
totalNumSamples=$((totalNumSamplesStr))
sampleRunTimeSecsStr=$(cat $monitorVarsFile | yq '.general.sample_run_time_secs') || exit
sampleRunTimeSecs=$((sampleRunTimeSecsStr))
testRunMinutes=$((sampleRunTimeSecs/60 * totalNumSamples))

if [ -z "$auto" ]; then rm -f $RUN_LOG_DIR/*.log; fi

rm -f $resultDir/*

echo;
echo "##############################################################################################################"
echo "# Starting Monitors"
echo
echo ">>> test run takes approx. $testRunMinutes minutes"
echo ">>> infrastructure   : $UC_NON_PERSISTENT_INFRASTRUCTURE"
echo ">>> cloud provider   : $cloudProvider"
echo ">>> utc start time   : "$(date -u +"%Y-%m-%d %H:%M:%S")
echo ">>> local start time : "$(date +"%Y-%m-%d %H:%M:%S")
echo
if [ -z "$auto" ]; then x=$(wait4Key); fi
echo

##############################################################################################################################
# Call monitor scripts
monitorScriptPids=""
for monitorScript in ${monitorScripts[@]}; do
  echo ">>> Start $monitorScript ..."
  # nohup $scriptDir/$callScript > $logFile $* 2>&1 &
  # $scriptDir/$monitorScript 2>&1 > $RUN_LOG_DIR/$monitorScript.log &
  nohup $scriptDir/$monitorScript > $RUN_LOG_DIR/$monitorScript.log  2>&1 &
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
# TODO: move to functions.sh
_getChildrenPids() {
  echo $1
  for p in $(ps -o pid=,ppid= | grep $1$ | cut -f1 -d' '); do
    _getChildrenPids $p
  done
}
getChildrenPids() {
  for p in $(ps -o pid=,ppid= | grep $1$ | cut -f1 -d' '); do
    _getChildrenPids $p
  done
}
##############################################################################################################################


##############################################################################################################################
# monitor if 1 has failed
FAILED=0
while true; do
  wait -n || {
    code="$?"
    if [ $code = "127" ]; then
      # 127: last background job has exited successfully
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
echo ">>> utc end time   : "$(date -u +"%Y-%m-%d %H:%M:%S")
echo ">>> local end time : "$(date +"%Y-%m-%d %H:%M:%S")

##############################################################################################################################
# Post Processing of Results
if [ -z "$auto" ]; then
  echo ">>> Post processing results ..."
    runScript="$scriptDir/../lib/post-process-results.sh"
    nohup $runScript > $RUN_LOG_DIR/post-process-results.sh.log 2>&1 &
    pid="$!"; if wait $pid; then echo; else echo ">>> ERROR: $runScript"; exit 1; fi
fi

##############################################################################################################################
# final output
if [ "$FAILED" -gt 0 ]; then
  echo ">>> ERROR: running monitors. see log files for details";
  ls -la $RUN_LOG_DIR/*.log
  if [ "$killCount" -eq 0 ]; then echo ">>> WARNING: failed monitors but not killed any children, expecting kills."; fi
  echo ">>> INFO: checking if any monitors & playbooks still running:"
  ps | grep run.monitor || true
  ps | grep ansible-playbook || true
  exit 1
fi

###
# The End.
