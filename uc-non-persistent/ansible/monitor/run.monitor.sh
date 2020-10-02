#!/bin/bash
# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# ---------------------------------------------------------------------------------------------

##############################################################################################################################
# Prepare
scriptDir=$(cd $(dirname "$0") && pwd);
source $scriptDir/.lib/functions.sh
scriptName=$(basename $(test -L "$0" && readlink "$0" || echo "$0"));
projectHome=${scriptDir%/ansible/*}
resultDirBase="$projectHome/test-results/stats"
resultDir="$resultDirBase/run.current"
resultDirLatest="$resultDirBase/run.latest"
monitorVarsFile=$(assertFile "$scriptDir/vars/monitor.vars.yml") || exit

export runId=$(date -u +"%Y-%m-%d-%H-%M-%S")
utc_start_time=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

pids=""
auto=$1

echo;
echo "##############################################################################################################"
echo "# Starting Monitors"
echo
countStr=$(cat $monitorVarsFile | yq '.general.count') || exit
count=$((countStr + 2))
echo ">>> running approx. $count minutes"
echo "    (change 'general.count' in '$monitorVarsFile')"
echo ">>> utc start time: $utc_start_time"
echo
if [ -z "$auto" ]; then x=$(wait4Key); fi

rm -f ./*.log
rm -f $resultDir/*

echo;

# echo "##############################################################################################################"
echo ">>> Start VPN Stats Monitor ..."
  $scriptDir/run.monitor.vpn-stats.sh 2>&1 > $scriptDir/run.monitor.vpn-stats.log &
  vpn_stats_pid=" $!"
  pids+=" $!"

# echo "##############################################################################################################"
echo ">>> Start Latency Stats Monitor ..."
  $scriptDir/run.monitor.latency.sh 2>&1 > $scriptDir/run.monitor.latency.log &
  latency_pid=" $!"
  pids+=" $!"

# echo "##############################################################################################################"
echo ">>> Start Latency Broker Node Stats Monitor ..."
  $scriptDir/run.monitor.brokernode.latency.sh 2>&1 > $scriptDir/run.monitor.brokernode.latency.log &
  brokernode_latency_pid=" $!"
  pids+=" $!"

# echo "##############################################################################################################"
echo ">>> Start Ping Latency Stats Monitor ..."
  $scriptDir/run.monitor.ping.sh 2>&1 > $scriptDir/run.monitor.ping.log &
  ping_pid=" $!"
  pids+=" $!"

# echo "##############################################################################################################"
echo ">>> Waiting for Processes to finish:"
for p in $pids; do
  ps $p
done

FAILED=0
for pid in $pids; do
  if wait $pid; then
    echo ">>> SUCCESS: Process $p"
  else
    echo ">>> FAILED: Process $p"; FAILED=1
  fi
done

if [ "$FAILED" -gt 0 ]; then
  echo ">>> ERROR: at least one monitor failed"; exit 1
fi
##############################################################################################################################
# Post Processing of Results

# copy docker compose deployed template to result dir
cp $projectHome/ansible/docker-image/*.deployed.yml "$resultDir/PubSub.docker-compose.$runId.yml"

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
echo ">>> Monitor Results in: $finalResultDir"
echo;echo;

###
# The End.
