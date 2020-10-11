#!/usr/bin/env bash
# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# ---------------------------------------------------------------------------------------------
clear

scriptDir=$(cd $(dirname "$0") && pwd);
scriptName=$(basename $(test -L "$0" && readlink "$0" || echo "$0"));
projectHome=${scriptDir%%/uc-common/*}

echo;
echo "##############################################################################################################"
echo "# Script: $scriptName"

source ./.lib/functions.sh

runScripts=(
  # create
  "./run.create-sc-service.sh"
  # get details
  "./run.get.sh"
)

for runScript in ${runScripts[@]}; do

  echo; echo "##############################################################################################################"
  echo "# calling: $runScript"

  $runScript

  if [[ $? != 0 ]]; then echo ">>> ERR:$runScript. aborting."; echo; exit 1; fi

done

###
# The End.
