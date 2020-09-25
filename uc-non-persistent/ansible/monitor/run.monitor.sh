#!/bin/bash
# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# ---------------------------------------------------------------------------------------------

clear

##############################################################################################################################
# Prepare

scriptDir=$(cd $(dirname "$0") && pwd);
scriptName=$(basename $(test -L "$0" && readlink "$0" || echo "$0"));
projectHome=${scriptDir%%/ansible/*}
resultDirBase="$projectHome/test-results/stats"
resultDir="$resultDirBase/run.latest"

rm -f ./*.log
rm -f $resultDir/*
export TZ=UTC0
timestamp=$(date +%Y-%m-%d-%H-%M-%S)
pids=""


echo;
echo "##############################################################################################################"
echo "# Start VPN Stats Monitor ..."
echo
  ./run.monitor.vpn-stats.sh 2>&1 > ./run.monitor.vpn-stats.log &
  pids+=" $!"

echo "##############################################################################################################"
echo "# Start Latency Stats Monitor ..."
echo
  ./run.monitor.latency.sh 2>&1 > ./run.monitor.latency.log &
  pids+=" $!"

echo "##############################################################################################################"
echo "# Start Ping Latency Stats Monitor ..."
echo
  ./run.monitor.ping.sh 2>&1 > ./run.monitor.ping.log &
  pids+=" $!"

echo "##############################################################################################################"
echo "# Waiting for Processes to finish ..."
echo
echo ">>> Processes:"
for p in $pids; do
  ps -ef $p
done
echo;echo;
for p in $pids; do
  if wait $p; then
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
finalResultDir="$resultDirBase/run.$timestamp"
mv $resultDir $finalResultDir
if [[ $? != 0 ]]; then echo ">>> ERROR moving resultDir=$resultDir."; echo; exit 1; fi

echo "##############################################################################################################"
echo "# Results in: $finalResultDir"
echo "# Log files:"
ls -l *.log
echo;echo;

###
# The End.
