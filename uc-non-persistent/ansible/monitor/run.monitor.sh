#!/bin/bash
# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# ---------------------------------------------------------------------------------------------

clear

##############################################################################################################################
# Prepare
source ./.lib/functions.sh
scriptDir=$(cd $(dirname "$0") && pwd);
scriptName=$(basename $(test -L "$0" && readlink "$0" || echo "$0"));
projectHome=${scriptDir%/ansible/*}
resultDirBase="$projectHome/test-results/stats"
resultDir="$resultDirBase/run.current"
resultDirLatest="$resultDirBase/run.latest"
monitorVarsFile=$(assertFile "$scriptDir/vars/monitor.vars.yml") || exit

export TZ=UTC0
export runId=$(date +%Y-%m-%d-%H-%M-%S)
pids=""

echo;
echo "##############################################################################################################"
echo "# Starting Monitors"
echo
countStr=$(cat $monitorVarsFile | yq '.general.count')
count=$((countStr + 2))
echo ">>> running approx. $count minutes"
echo "    (change 'general.count' in '$monitorVarsFile')"
echo
x=$(wait4Key)

rm -f ./*.log
rm -f $resultDir/*

echo;
echo "##############################################################################################################"
echo "# Start VPN Stats Monitor ..."
echo
  ./run.monitor.vpn-stats.sh 2>&1 > ./run.monitor.vpn-stats.log &
  vpn_stats_pid=" $!"
  pids+=" $!"

echo "##############################################################################################################"
echo "# Start Latency Stats Monitor ..."
echo
  ./run.monitor.latency.sh 2>&1 > ./run.monitor.latency.log &
  latency_pid=" $!"
  pids+=" $!"

echo "##############################################################################################################"
echo "# Start Ping Latency Stats Monitor ..."
echo
  ./run.monitor.ping.sh 2>&1 > ./run.monitor.ping.log &
  ping_pid=" $!"
  pids+=" $!"

echo "##############################################################################################################"
echo "# Waiting for Processes to finish ..."
echo
echo ">>> Processes:"
for p in $pids; do
  ps $p
done
echo;echo;

for pid in $pids; do
  if wait $pid; then
    echo; echo ">>> SUCCESS: Process $p"
  else
    echo; echo ">>> FAILED: Process $p"
  fi
done
echo

##############################################################################################################################
# Post Processing of Results

# copy docker compose deployed template to result dir
cp $projectHome/ansible/docker-image/*.deployed.yml $resultDir

##############################################################################################################################
# Move ResultDir to Timestamp
finalResultDir="$resultDirBase/run.$runId"
mv $resultDir $finalResultDir
if [[ $? != 0 ]]; then echo ">>> ERROR moving resultDir=$resultDir."; echo; exit 1; fi
cd $resultDirBase
rm -f $resultDirLatest
ln -s $finalResultDir $resultDirLatest
cd $scriptDir

echo "##############################################################################################################"
echo "# Results in: $finalResultDir"
echo "# Log files:"
ls -l *.log
echo;echo;

###
# The End.
