#!/usr/bin/env bash
# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# ---------------------------------------------------------------------------------------------


#####################################################################################
# settings

    scriptDir=$(cd $(dirname "$0") && pwd);
    scriptName=$(basename $(test -L "$0" && readlink "$0" || echo "$0"));
    source $scriptDir/.lib/functions.sh

    stateDir="$scriptDir/state"
    stateFile=$(assertFile $stateDir/create.state.json) || exit

#####################################################################################
# vars

  state=$(cat $stateFile | jq .)
  resourceGroup=$( echo $state | jq -r '.resourceGroup' )
  

echo ">>> Deleting Resource Group '$resourceGroup' ..."
echo
  az group delete \
    --name $resourceGroup \
    --verbose
  if [[ $? != 0 ]]; then echo ">>> ERROR: deleting resource group"; exit 1; fi
echo ">>> Success."

#####################################################################################
# Remove state
rm -rf $stateDir


###
# The End.
