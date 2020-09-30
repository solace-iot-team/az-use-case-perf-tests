#!/bin/bash
# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# ---------------------------------------------------------------------------------------------
clear

scriptDir=$(cd $(dirname "$0") && pwd);
scriptName=$(basename $(test -L "$0" && readlink "$0" || echo "$0"));
projectHome=${scriptDir%%/uc-common/*}
source $projectHome/uc-common/.lib/functions.sh
stateTemplateFile=$(assertFile "$scriptDir/lib/template.adx.state.json") || exit
stateDir="$scriptDir/state"
stateFile=$(assertFile "$stateDir/az.adx.state.json") || exit
echo;
echo "##############################################################################################################"
echo "# Script: $scriptName $*"
##############################################################################################################################
# Args
runDir=$1
if [[ ! -d "$runDir" ]]; then echo " >>> ERROR: run directory not found: '$runDir'"; exit 1; fi
metaFile="$runDir/run.meta.json"
if [[ ! -f "$metaFile" ]]; then echo " >>> ERROR: meta file not found: '$metaFile'"; exit 1; fi

##############################################################################################################################
# State vars
stateJson=$(cat $stateFile | jq -r . ) || exit
metaJson=$(cat $metaFile | jq -r . ) || exit
storageConnectionString=$(echo $stateJson | jq -r '.state.storage.connectionString')
storageContainerName=$(echo $stateJson | jq -r '.vars.storage.containerName')
testCloudProvider=$(echo $metaJson | jq -r '.meta.cloud_provider')
testUseCase=$(echo $metaJson | jq -r '.meta.use_case')
testRunId=$(echo $metaJson | jq -r '.meta.run_id')
# path vars
prefixPath="$testCloudProvider/$testUseCase"
statsPaths=(
  "ping"
  "latency"
  "vpn"
)
metaPath="meta"
metaFilePattern="run.meta.json"
dockerComposePath="docker"
dockerComposeFilePattern="PubSub.docker-compose.*.yml"

##############################################################################################################################
# Upload stats
for statsPath in ${statsPaths[@]}; do
  echo " >>> Batch upload Tests Results: $statsPath..."
  destPath="$prefixPath/$statsPath"
  resp=$(az storage blob upload-batch \
    --connection-string $storageConnectionString \
    --destination $storageContainerName \
    --source $runDir \
    --pattern "$statsPath-stats.*.json" \
    --destination-path "$destPath" \
    --verbose)
  echo " >>> Success."
done
##############################################################################################################################
# Upload meta
echo " >>> Upload Tests Results Meta..."
destPath="$prefixPath/$metaPath"
resp=$(az storage blob upload-batch \
  --connection-string $storageConnectionString \
  --destination $storageContainerName \
  --source $runDir \
  --pattern "$metaFilePattern" \
  --destination-path "$destPath" \
  --verbose)
echo " >>> Success."

echo " >>> Upload Tests Docker Compose Template ..."
destPath="$prefixPath/$dockerComposePath"
resp=$(az storage blob upload-batch \
  --connection-string $storageConnectionString \
  --destination $storageContainerName \
  --source $runDir \
  --pattern "$dockerComposeFilePattern" \
  --destination-path "$destPath" \
  --verbose)
echo " >>> Success."

##############################################################################################################################
# Manual step
dataIngestionUri=$(echo $stateJson | jq -r '.state.adx.dataIngestionUri')
microsoftBlobEndpoint=$(echo $stateJson | jq -r '.state.storage.microsoftBlobEndpoint')
sasToken=$(echo $stateJson | jq -r '.state.storage.sasToken')
link2StorageBase="$microsoftBlobEndpoint$storageContainerName/$prefixPath"

echo;
echo "##############################################################################################################"
echo "# Manual step: Ingest new run"
echo "# Login to Azure Portal"
echo "#   - go to: $dataIngestionUri"
echo "#   - Ping: table: ping, source type: From container"
echo "#   - Latency: table: latency, source type: From container"
echo "#   - Vpn: table: vpn, source type: From container"
echo "#   - Meta: table: meta, source type: From container"
echo "#   - Links to storage: "
for statsPath in ${statsPaths[@]}; do
  echo "    $statsPath: $link2StorageBase/$statsPath?$sasToken"
done
  echo "    $metaPath: $link2StorageBase/$metaPath?$sasToken"
echo

###
# The End.
