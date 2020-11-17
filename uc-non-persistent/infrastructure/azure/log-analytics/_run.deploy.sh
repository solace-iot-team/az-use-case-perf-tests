#!/usr/bin/env bash
# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Microsoft Corporation, Paolo Salvatori (paolos@microsoft.com)
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# ---------------------------------------------------------------------------------------------

##############################################################################################################################
# Prepare
scriptDir=$(cd $(dirname "$0") && pwd);
scriptName=$(basename $(test -L "$0" && readlink "$0" || echo "$0"));
projectHome=${scriptDir%/uc-non-persistent/*}
usecaseHome=$projectHome/uc-non-persistent
source $projectHome/.lib/functions.sh

############################################################################################################################
# Environment Variables

  if [ -z "$CLOUD_PROVIDER_ID" ]; then echo ">>> ERROR: - $scriptName - missing env var:CLOUD_PROVIDER_ID"; exit 1; fi
  if [ -z "$INFRA_CONFIG_ID" ]; then echo ">>> ERROR: - $scriptName - missing env var:INFRA_CONFIG_ID"; exit 1; fi
  if [ -z "$BROKER_NODES_FILE" ]; then echo ">>> ERROR: - $scriptName - missing env var:BROKER_NODES_FILE"; exit 1; fi
  if [ -z "$SDKPERF_NODES_FILE" ]; then echo ">>> ERROR: - $scriptName - missing env var:SDKPERF_NODES_FILE"; exit 1; fi
  if [ -z "$ENV_FILE" ]; then echo ">>> ERROR: - $scriptName - missing env var:ENV_FILE"; exit 1; fi

##############################################################################################################################
# Checks

  parametersFile=$(assertFile $scriptDir/azuredeploy.parameters.json) || exit
  templateFile=$(assertFile $scriptDir/deploy-arm-template.json) || exit

  brokerNodesFile=$(assertFile $BROKER_NODES_FILE) || exit
  sdkPerfNodesFile=$(assertFile $SDKPERF_NODES_FILE) || exit
  envFile=$(assertFile $ENV_FILE) || exit

############################################################################################################################
# Settings
brokerNodesJSON=$( cat $brokerNodesFile | jq . )
sdkPerfNodesJSON=$( cat $sdkPerfNodesFile | jq . )
envJSON=$( cat $envFile | jq . )

projectPrefix=${INFRA_CONFIG_ID%%-*}
resourceGroupName=$(echo $envJSON | jq -r '.env.proximity_placement_group.details[0].resource_group_name' )
location=$(echo $envJSON | jq -r '.env.region' )
workspaceName="$projectPrefix-sdkperf-log-analytics-ws"
workspaceSku="PerGB2018"


# echo "projectPrefix=$projectPrefix"
# echo "location=$location"
# echo "workspaceName=$workspaceName"

virtualMachines=()
for node_name in $(echo $brokerNodesJSON | jq -r '.broker_nodes[].name' ); do
  virtualMachines+=($node_name)
done
for node_name in $(echo $sdkPerfNodesJSON | jq -r '.latency_nodes[].name' ); do
  virtualMachines+=($node_name)
done
for node_name in $(echo $sdkPerfNodesJSON | jq -r '.publisher_nodes[].name' ); do
  virtualMachines+=($node_name)
done
for node_name in $(echo $sdkPerfNodesJSON | jq -r '.consumer_nodes[].name' ); do
  virtualMachines+=($node_name)
done

# Read subscription id and name for the current subscription
subscriptionId=$(az account show --query id --output tsv)
subscriptionName=$(az account show --query name --output tsv)

##############################################################################################################################
# Create

echo ">>> Validate that resource group [$resourceGroupName] exists ..."
  resp=$(az group show \
    --name "$resourceGroupName")
  code=$?; if [[ $code != 0 ]]; then echo ">>> ERROR: - $code - $scriptName - resource group [$resourceGroupName] does not exist"; exit 1; fi
  # echo $resp | jq
  echo " >>> Success."

# Check if the Log Analytics workspace exists, if not create it
echo ">>> Check/Create Log Analytics Workspace [$workspaceName] ..."
  resp=$(az monitor log-analytics workspace show \
          --resource-group "$resourceGroupName" \
          --workspace-name "$workspaceName")
  code=$?
  # code==3 : does not exist
  if [[ $code != 0 && $code != 3 ]]; then echo ">>> ERROR: - $code - $scriptName - Failed to check log analytics workspace [$workspaceName]"; exit 1; fi

  if [[ $code == 3 ]]; then
      echo ">>> INFO: workspace does not exist, creating it ..."
      # Deploy Log Analytics via ARM template
      az deployment group create \
          --name $resourceGroupName"_logAnalytics_Deployment" \
          --resource-group $resourceGroupName \
          --template-file $templateFile \
          --parameters $parametersFile \
          --parameters workspaceName="$workspaceName" workspaceSku="$workspaceSku" location="$location" \
          --verbose
      code=$?; if [[ $code != 0 ]]; then echo ">>> ERROR: - $code - $scriptName - Failed to create log analytics workspace [$workspaceName]"; exit 1; fi
  else
      echo ">>> INFO: workspace [$workspaceName] already exists"
  fi
  echo " >>> Success."

# Retrieve Log Analytics workspace key
echo ">>> Retrieving the primary key for the log analytics workspace: [$workspaceName] ..."
  workspaceKey=$(
      az monitor log-analytics workspace get-shared-keys \
          --resource-group "$resourceGroupName" \
          --workspace-name "$workspaceName" \
          --query primarySharedKey \
          --output tsv
  )
  code=$?; if [[ $code != 0 ]]; then echo ">>> ERROR: - $code - $scriptName - Failed to retrieve key for workspace [$workspaceName]"; exit 1; fi

  if [[ ! -n $workspaceKey ]]; then echo ">>> ERROR: Failed to retrieve the primary key for workspace [$workspaceName]"; exit 1; fi

echo "workspaceKey=$workspaceKey"

# Retrieve Log Analytics resource id
echo ">>> Retrieving the resource id for workspace [$workspaceName] ..."
  workspaceId=$(
      az monitor log-analytics workspace show \
          --resource-group "$resourceGroupName" \
          --workspace-name "$workspaceName" \
          --query customerId \
          --output tsv
  )
  code=$?; if [[ $code != 0 ]]; then echo ">>> ERROR: - $code - $scriptName - Failed to retrieve key for workspace [$workspaceName]"; exit 1; fi

  if [[ ! -n $workspaceId ]]; then echo ">>> ERROR: Failed to retrieve id for workspace [$workspaceName]"; exit 1; fi

  echo "workspaceId=$workspaceId"


protectedSettings="{\"workspaceKey\":\"$workspaceKey\"}"
settings="{\"workspaceId\": \"$workspaceId\"}"

# Deploy VM extension for the virtual machines in the same resource group
for virtualMachine in ${virtualMachines[@]}; do

  echo ">>> Creating [OmsAgentForLinux] VM extension for vm [$virtualMachine] ..."

    doCreate=1
    resp=$(az vm extension show \
      --resource-group "$resourceGroupName" \
      --vm-name "$virtualMachine" \
      --name OmsAgentForLinux \
      --verbose)
    code=$?; if [[ $code != 0 && $code != 3 ]]; then echo ">>> ERROR: - $code - $resp - $scriptName - Failed to show vm extension [OmsAgentForLinux] for vm [$virtualMachine]"; exit 1; fi
    # exists:
    # code == 0, resp.provisioningState==Succeeded
    if [[ $code == 0 ]]; then
      provisioningState=$(echo $resp | jq -r '.provisioningState' )
      if [[ "$provisioningState" == "Succeeded" ]]; then doCreate=0; fi
    fi
    if [[ $doCreate == 1 ]]; then
      # delete it beforehand - even if it doesn't exist
      resp=$(az vm extension delete \
        --resource-group "$resourceGroupName" \
        --vm-name "$virtualMachine" \
        --name OmsAgentForLinux \
        --verbose)
      code=$?; if [[ $code != 0 ]]; then echo ">>> ERROR: - $code - $resp - $scriptName - Failed to create vm extension [OmsAgentForLinux] for vm [$virtualMachine]"; exit 1; fi

      resp=$(az vm extension set \
          --resource-group "$resourceGroupName" \
          --vm-name "$virtualMachine" \
          --name OmsAgentForLinux \
          --publisher Microsoft.EnterpriseCloud.Monitoring \
          --protected-settings "$protectedSettings" \
          --settings "$settings" \
          --verbose )
      code=$?; if [[ $code != 0 ]]; then echo ">>> ERROR: - $code - $resp - $scriptName - Failed to create vm extension [OmsAgentForLinux] for vm [$virtualMachine]"; exit 1; fi

      resp=$(az vm extension wait \
            --created \
            --name OmsAgentForLinux \
            --resource-group "$resourceGroupName" \
            --vm-name "$virtualMachine" \
            --verbose)
      code=$?; if [[ $code != 0 ]]; then echo ">>> ERROR: - $code - $resp - $scriptName - Failed to wait for vm extension [OmsAgentForLinux] for vm [$virtualMachine]"; exit 1; fi
    else
      echo ">>> INFO: vm extension [OmsAgentForLinux] for vm [$virtualMachine] already exists"
    fi
    resp=$(az vm extension show \
      --resource-group "$resourceGroupName" \
      --vm-name "$virtualMachine" \
      --name OmsAgentForLinux \
      --verbose)
    code=$?; if [[ $code != 0 ]]; then echo ">>> ERROR: - $code - $resp - $scriptName - Failed to show vm extension [OmsAgentForLinux] for vm [$virtualMachine]"; exit 1; fi

    echo ">>> Success creating [OmsAgentForLinux] VM extension for vm [$virtualMachine]"
    echo ">>> Status:"
    echo $resp | jq .


    echo ">>> Creating [DependencyAgentLinux] VM extension for vm [$virtualMachine] ..."
    resp=$(az vm extension set \
        --resource-group "$resourceGroupName" \
        --vm-name "$virtualMachine" \
        --name DependencyAgentLinux \
        --publisher Microsoft.Azure.Monitoring.DependencyAgent \
        --verbose )
    code=$?; if [[ $code != 0 ]]; then echo ">>> ERROR: - $code - $resp - $scriptName - Failed to create vm extension [DependencyAgentLinux] for vm [$virtualMachine]"; exit 1; fi

    resp=$(az vm extension wait \
          --created \
          --name DependencyAgentLinux \
          --resource-group "$resourceGroupName" \
          --vm-name "$virtualMachine" \
          --verbose)
    code=$?; if [[ $code != 0 ]]; then echo ">>> ERROR: - $code - $resp - $scriptName - Failed to wait for vm extension [DependencyAgentLinux] for vm [$virtualMachine]"; exit 1; fi

    resp=$(az vm extension show \
      --resource-group "$resourceGroupName" \
      --vm-name "$virtualMachine" \
      --name DependencyAgentLinux \
      --verbose)
    code=$?; if [[ $code != 0 ]]; then echo ">>> ERROR: - $code - $resp - $scriptName - Failed to show vm extension [DependencyAgentLinux] for vm [$virtualMachine]"; exit 1; fi

    echo ">>> Success creating [DependencyAgentLinux] VM extension for vm [$virtualMachine]"
    echo ">>> Status:"
    echo $resp | jq .

done


###
# The End.
