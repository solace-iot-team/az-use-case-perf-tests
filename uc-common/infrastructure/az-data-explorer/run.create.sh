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
stateTemplateFile=$(assertFile "$scriptDir/lib/template.adx.state.json") || exit
stateDir="$scriptDir/state"
stateFile="$stateDir/az.adx.state.json"
echo;
echo "##############################################################################################################"
echo "# Script: $scriptName"

##############################################################################################################################
# Create vars
varsJson=$(cat $varsFile | jq -r . ) || exit
prefix=$(echo $varsJson | jq -r '.prefix')
resourceGroupName=$prefix$(echo $varsJson | jq -r '.resourceGroupName')
location=$(echo $varsJson | jq -r '.location')
storageAccountName=$prefix$(echo $varsJson | jq -r '.storage.accountName')
storageAccountSku=$(echo $varsJson | jq -r '.storage.sku')
storageContainerName=$(echo $varsJson | jq -r '.storage.containerName')
kustoClusterName=$prefix$(echo $varsJson | jq -r '.adx.clusterName')
kustoSku=$(echo $varsJson | jq -r '.adx.sku')
kustoCapacity=$(echo $varsJson | jq -r '.adx.capacity')
kustoDBName=$(echo $varsJson | jq -r '.adx.dBName')
# copy vars to state
stateJson=$(cat $stateTemplateFile | jq -r .) || exit
export varsJson
stateJson=$(echo $stateJson | jq -r '.vars=(env.varsJson | fromjson)')
##############################################################################################################################
# Create state directory
mkdir $stateDir > /dev/null 2>&1
rm -f $stateDir/*.*
##############################################################################################################################
# Create Resources

echo " >>> Create Resource Group ..."
resp=$(az group create \
  --name $resourceGroupName \
  --location "$location" \
  --verbose)
if [[ $? != 0 ]]; then echo " >>> ERR: creating resource group"; exit 1; fi
echo $resp | jq
echo " >>> Success."

echo " >>> Create Storage Account ..."
resp=$(az storage account create \
        --name $storageAccountName \
        --resource-group $resourceGroupName \
        --location "$location" \
        --sku $storageAccountSku \
        --enable-hierarchical-namespace true \
        --kind StorageV2 \
        --verbose)
echo " >>> Success."

echo " >>> Get Storage Account Connection String..."
resp=$(az storage account show-connection-string \
  --resource-group $resourceGroupName \
  --name $storageAccountName \
  --verbose)
echo " >>> Success."
# add connection string to state
export connectionString=$(echo $resp | jq -r '.connectionString')
stateJson=$(echo $stateJson | jq -r '.state.storage.connectionString=env.connectionString')

echo " >>> Create Storage Container ..."
resp=$(az storage container create \
        --name $storageContainerName \
        --public-access blob \
        --connection-string $connectionString \
        --verbose)
echo " >>> Success."


##############################################################################################################################
# Manual step
echo;
echo "##############################################################################################################"
echo "# Manual step:"
echo "# Login to Azure Portal"
echo "#  - go to the storage account: $resourceGroupName:$storageAccountName"
echo "#  - click: Firewalls and virtual networks"
echo "#    - enable: Microsoft network routing endpoint"
echo "#    - save"
echo
x=$(wait4Key)


echo " >>> Generate SAS Token..."
resp=$(az storage account generate-sas \
  --connection-string $connectionString \
  --expiry 2030-01-01 \
  --permissions acdlpruw \
  --resource-types sco \
  --services bfqt \
  --verbose)
echo " >>> Success."
# add token to state
sasToken=$(echo $resp | jq -r . ) || exit
export sasToken
stateJson=$(echo $stateJson | jq -r '.state.storage.sasToken=env.sasToken')

echo " >>> Get storage account details ..."
resp=$(az storage account list \
  --resource-group $resourceGroupName \
  --verbose)
echo " >>> Success."
# checks
routingPreference_publishMicrosoftEndpoints=$(echo $resp | jq -r '.[0].routingPreference.publishMicrosoftEndpoints')
if [ "$routingPreference_publishMicrosoftEndpoints" != "true" ]; then
  echo ">>> ERROR: routingPreference.publishMicrosoftEndpoints is not set to true"; exit 1
fi
# add blob endpoint to state
export microsoftBlobEndpoint=$(echo $resp | jq -r '.[0].primaryEndpoints.microsoftEndpoints.blob')
stateJson=$(echo $stateJson | jq -r '.state.storage.microsoftBlobEndpoint=env.microsoftBlobEndpoint')

##############################################################################################################################
# Kusto
echo " >>> Create Kusto Cluster ..."
resp=$(az kusto cluster create \
  --name $kustoClusterName \
  --resource-group $resourceGroupName \
  --location "$location" \
  --sku $kustoSku \
  --capacity $kustoCapacity \
  --verbose)
echo " >>> Success."

echo " >>> Show Kusto Cluster ..."
resp=$(az kusto cluster show \
 --name $kustoClusterName \
 --resource-group $resourceGroupName \
 --verbose)
echo " >>> Success."
# add ingestion uri to state
export dataIngestionUri=$(echo $resp | jq -r '.dataIngestionUri')
stateJson=$(echo $stateJson | jq -r '.state.adx.dataIngestionUri=env.dataIngestionUri')

echo " >>> Create Kusto Database ..."
resp=$(az kusto database create \
  --cluster-name $kustoClusterName \
  --resource-group $resourceGroupName \
  --name $kustoDBName \
  --verbose)
echo " >>> Success."

##############################################################################################################################
# Save state
echo $stateJson | jq -r . > $stateFile || exit
echo $stateJson | jq || exit


###
# The End.
