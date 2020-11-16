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
# no underscores
workspaceName="devel1-SDKPerfLogAnalyticsWS"

# Read subscription id and name for the current subscription
subscriptionId=$(az account show --query id --output tsv)
subscriptionName=$(az account show --query name --output tsv)


##############################################################################################################################
# Delete

# Check if the Log Analytics workspace exists, if it does, delete it
echo ">>> Check/Delete Log Analytics Workspace [$workspaceName] ..."
  resp=$(az monitor log-analytics workspace show \
          --resource-group "$resourceGroupName" \
          --workspace-name "$workspaceName")
  code=$?
  # code==3 : does not exist
  echo $resp
  echo "code=$code"

  if [[ $code == 0 ]]; then
      echo ">>> INFO: workspace exists, deleting it ..."

      az monitor log-analytics workspace delete \
        --resource-group $resourceGroupName \
        --workspace-name "$workspaceName" \
        --force true \
        --yes \
        --verbose

      if [[ $? != 0 ]]; then echo ">>> ERROR: Failed to delete log analytics workspace [$workspaceName]"; exit 1; fi
  else
      echo ">>> INFO: workspace [$workspaceName] does not exist"
  fi
  echo " >>> Success."


###
# The End.
