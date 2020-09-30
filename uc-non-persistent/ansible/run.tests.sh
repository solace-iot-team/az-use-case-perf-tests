#!/bin/bash
# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# ---------------------------------------------------------------------------------------------

clear

##############################################################################################################################
# Prepare
scriptDir=$(cd $(dirname "$0") && pwd);
source $scriptDir/.lib/functions.sh
scriptName=$(basename $(test -L "$0" && readlink "$0" || echo "$0"));
projectHome=${scriptDir%/ansible/*}

export ANSIBLE_VERBOSITY=0

echo;
echo "##############################################################################################################"
echo "# Running tests: start load, run monitors, stop load ..."
echo
echo

echo " >>> Starting Load ..."
  $scriptDir/start.load.sh > $scriptDir/start.load.log
  if [[ $? != 0 ]]; then echo ">>> ERROR starting load"; echo; exit 1; fi

echo " >>> Running Monitors ..."
  $scriptDir/monitor/run.monitor.sh auto
  if [[ $? != 0 ]]; then echo ">>> ERROR running monitors"; echo; exit 1; fi

echo " >>> Stop Load ..."
  $scriptDir/stop.load.sh > $scriptDir/stop.load.log
  if [[ $? != 0 ]]; then echo ">>> ERROR stopping load"; echo; exit 1; fi

echo " >>> DONE"; echo

###
# The End.
