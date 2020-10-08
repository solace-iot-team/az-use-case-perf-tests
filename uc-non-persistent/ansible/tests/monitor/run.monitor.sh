#!/bin/bash
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

############################################################################################################################
# Set monitor scripts
monitorScripts=(
  "run.monitor.vpn-stats.sh"
  # "run.monitor.latency.sh"
  # "run.monitor.brokernode.latency.sh"
  # "run.monitor.ping.sh"
)

############################################################################################################################
# Check if any monitors running
let count=0
for monitorScript in ${monitorScripts[@]}; do
  monitorScriptPids=( $(ps -ef | grep $monitorScript | awk '{ print $2 }' ) )
  # echo "monitorScriptPids = ${monitorScriptPids[@]}"
  let countMonitors=${#monitorScriptPids[@]}
  if [ "$countMonitors" -gt 1 ]; then
    let "count+=1";
    echo ">>> ERROR: monitor: $monitorScript already running"
  fi
done
if [ "$count" -gt 0 ]; then
  echo ">>> ERROR: found $count instance(s) of monitors already running. exiting."; exit 1
fi

##############################################################################################################################
# Prepare
cloudProvider=${UC_NON_PERSISTENT_INFRASTRUCTURE%%.*}
resultDirBase="$projectHome/test-results/stats/$UC_NON_PERSISTENT_INFRASTRUCTURE"
resultDir="$resultDirBase/run.current"
resultDirLatest="$resultDirBase/run.latest"
# Set for all monitors
export runId=$(date -u +"%Y-%m-%d-%H-%M-%S")
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
pids=""
for monitorScript in ${monitorScripts[@]}; do
  echo ">>> Start $monitorScript ..."
  # nohup $scriptDir/$callScript > $logFile $* 2>&1 &
  # $scriptDir/$monitorScript 2>&1 > $RUN_LOG_DIR/$monitorScript.log &
  nohup $scriptDir/$monitorScript > $RUN_LOG_DIR/$monitorScript.log  2>&1 &
  pids+=" $!"
done

# echo "##############################################################################################################"
echo ">>> Waiting for Processes to finish:"
for pid in $pids; do
  ps -ef $pid
done

FAILED=0
for pid in $pids; do
  if wait $pid; then
    echo ">>> SUCCESS: Process $pid"
  else
    echo ">>> ERROR: Process $pid"; FAILED=1
  fi
done

if [ "$FAILED" -gt 0 ]; then
  echo ">>> ERROR: at least one monitor failed. see log files for details.";
  ls -la $RUN_LOG_DIR/*.log
  exit 1
fi
##############################################################################################################################
# Post Processing of Results

# copy docker compose deployed template to result dir
cp $projectHome/ansible/docker-image/*.deployed.yml "$resultDir/PubSub.docker-compose.$runId.yml"
# copy all log files to result dir
mkdir $resultDir/logs > /dev/null 2>&1
cp $RUN_LOG_DIR/*.log "$resultDir/logs"

##############################################################################################################################
# Move ResultDir to Timestamp
finalResultDir="$resultDirBase/run.$runId"
mv $resultDir $finalResultDir
if [[ $? != 0 ]]; then echo ">>> ERROR moving resultDir=$resultDir."; echo; exit 1; fi
cd $resultDirBase
rm -f $resultDirLatest
ln -s $finalResultDir $resultDirLatest
cd $scriptDir

# echo "##############################################################################################################"
echo
echo ">>> utc end time   : "$(date -u +"%Y-%m-%d %H:%M:%S")
echo ">>> local end time : "$(date +"%Y-%m-%d %H:%M:%S")
echo ">>> Monitor Results in: $finalResultDir"
echo;echo;


###
# The End.
