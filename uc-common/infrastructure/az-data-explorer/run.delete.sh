#!/usr/bin/env bash
# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# ---------------------------------------------------------------------------------------------
clear

scriptDir=$(cd $(dirname "$0") && pwd);
scriptName=$(basename $(test -L "$0" && readlink "$0" || echo "$0"));
projectHome=${scriptDir%%/uc-common/*}
source $projectHome/uc-common/.lib/functions.sh
varsFile=$(assertFile "$scriptDir/vars/adx.vars.json") || exit
stateDir="$scriptDir/state"
stateFile=$(assertFile "$stateDir/az.adx.state.json") || exit
echo;
echo "##############################################################################################################"
echo "# Script: $scriptName"
echo
##############################################################################################################################
# Create vars
varsJson=$(cat $varsFile | jq -r . ) || exit
prefix=$(echo $varsJson | jq -r '.prefix')
resourceGroupName=$prefix$(echo $varsJson | jq -r '.resourceGroupName')

##############################################################################################################################
# Delete Resources

echo " >>> Check that Resource Group exists: '$resourceGroupName' ..."
resp=$(az group exists \
  --resource-group $resourceGroupName \
  --verbose)
if [[ $? != 0 ]]; then echo " >>> ERR: checking resource group"; exit 1; fi
if [ "$resp" != "true" ]; then
  echo " >>> Resource group: '$resourceGroupName' does not exist"; echo; exit
fi
echo " >>> Success."

echo " >>> Delete Resource Group '$resourceGroupName' ..."
  az group delete \
    --name $resourceGroupName \
    --verbose
  if [[ $? != 0 ]]; then echo " >>> ERR: deleting resource group"; exit 1; fi
echo " >>> Success."

##############################################################################################################################
# Delete state
rm -rf $stateFile


###
# The End.
