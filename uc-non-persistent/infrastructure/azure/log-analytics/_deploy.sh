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

############################################################################################################################
# Manual settings for now
# Variables
# match infrastructureId deployment in shared-setup
resourceGroupName="devel1-sdkperf_resgrp"
location="WestEurope"
# no underscores
workspaceName="devel1-SDKPerfLogAnalyticsWS"

# Virtual machines
# shared-setup: azure.devel1-standalone.broker-nodes.json
#   - broker_nodes[*].name
# shared-setup: azure.devel1-standalone.sdkperf-nodes.json
#   - latency_nodes[*].name
#   - publisher_nodes[*].name
#   - consumer_nodes[*].name
virtualMachines=(
  "devel1-solacebroker-node-0"

  "devel1-consumer-node-0"
  "devel1-consumer-node-1"
  "devel1-consumer-node-2"
  "devel1-consumer-node-3"

  "devel1-latency-node-0"
  "devel1-publisher-node-0"

)


############################################################################################################################
# Static Settings

workspaceSku="PerGB2018"
workspaceSku="pergb2018"

# ARM template and parameters files
templateFile="./deploy-arm-template.json"
parametersFile="./azuredeploy.parameters.json"


# Read subscription id and name for the current subscription
subscriptionId=$(az account show --query id --output tsv)
subscriptionName=$(az account show --query name --output tsv)

echo ">>> DEBUG: subscriptionId=$subscriptionId"
echo ">>> DEBUG: subscriptionName=$subscriptionName"

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
  echo $resp
  echo "code=$code"

  if [[ $code == 3 ]]; then
      echo ">>> INFO: workspace does not exist, creating it ..."
      # Deploy Log Analytics via ARM template
      az deployment group create \
          --name $resourceGroupName"_logAnalytics_Deployment" \
          --resource-group $resourceGroupName \
          --template-file $templateFile \
          --parameters $parametersFile \
          --parameters "workspaceName=$workspaceName workspaceSku=$workspaceSku location=$location" \
          --verbose
      code=$?; if [[ $code != 0 ]]; then echo ">>> ERROR: - $code - $scriptName - Failed to create log analytics workspace [$workspaceName]"; exit 1; fi
  else
      echo ">>> INFO: workspace [$workspaceName] already exists"
  fi
  echo " >>> Success."

exit 1

# Retrieve Log Analytics workspace key
echo "Retrieving the primary key for the [$workspaceName] Log Analytics workspace..."
workspaceKey=$(
    az monitor log-analytics workspace get-shared-keys \
        --resource-group "$resourceGroupName" \
        --workspace-name "$workspaceName" \
        --query primarySharedKey \
        --output tsv
)

if [[ -n $workspaceKey ]]; then
    echo "Primary key for the [$workspaceName] Log Analytics workspace successfully retrieved."
else
    echo "Failed to retrieve the primary key for the [$workspaceName] Log Analytics workspace."
    exit
fi

# Retrieve Log Analytics resource id
echo "Retrieving the resource id for the [$workspaceName] Log Analytics workspace..."
workspaceId=$(
    az monitor log-analytics workspace show \
        --resource-group "$resourceGroupName" \
        --workspace-name "$workspaceName" \
        --query customerId \
        --output tsv
)

if [[ -n $workspaceId ]]; then
    echo "Resource id for the [$workspaceName] Log Analytics workspace successfully retrieved."
else
    echo "Failed to retrieve the resource id for the [$workspaceName] Log Analytics workspace."
    exit
fi

protectedSettings="{\"workspaceKey\":\"$workspaceKey\"}"
settings="{\"workspaceId\": \"$workspaceId\"}"

# Deploy VM extension for the virtual machines in the same resource group
for virtualMachine in ${virtualMachines[@]}; do
    echo "Creating [OmsAgentForLinux] VM extension for the [$virtualMachine] virtual machine..."
    error=$(az vm extension set \
        --resource-group "$resourceGroupName" \
        --vm-name "$virtualMachine" \
        --name OmsAgentForLinux \
        --publisher Microsoft.EnterpriseCloud.Monitoring \
        --protected-settings "$protectedSettings" \
        --settings "$settings")

    if [[ $? == 0 ]]; then
        echo "[OmsAgentForLinux] VM extension for the [$virtualMachine] virtual machine successfully created."
    else
        echo "Failed to create the [OmsAgentForLinux] VM extension for the [$virtualMachine] virtual machine."
        echo $error
        exit
    fi

    echo "Creating [DependencyAgentLinux] VM extension for the [$virtualMachine] virtual machine..."
    error=$(az vm extension set \
        --resource-group "$resourceGroupName" \
        --vm-name "$virtualMachine" \
        --name DependencyAgentLinux \
        --publisher Microsoft.Azure.Monitoring.DependencyAgent)

    if [[ $? == 0 ]]; then
        echo "[DependencyAgentLinux] VM extension for the [$virtualMachine] virtual machine successfully created."
    else
        echo "Failed to create the [DependencyAgentLinux] VM extension for the [$virtualMachine] virtual machine."
        echo $error
        exit
    fi
done
