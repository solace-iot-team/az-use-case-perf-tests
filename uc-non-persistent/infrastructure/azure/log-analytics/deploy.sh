#!/bin/bash

# Variables
resourceGroupName="SolaceRG"
location="WestEurope"
workspaceName="MandalorianLogAnalytics"
workspaceSku="PerGB2018"

# ARM template and parameters files
template="./azuredeploy.json"
parameters="./azuredeploy.parameters.json"

# Virtual machines
virtualMachines=("TestVM1" "TestVM2")

# Read subscription id and name for the current subscription
subscriptionId=$(az account show --query id --output tsv)
subscriptionName=$(az account show --query name --output tsv)

# This function creates a resource group
createResourceGroup() {
    local resourceGroupName=$1
    local location=$2

    # Parameters validation
    if [[ -z $resourceGroupName ]]; then
        echo "The resourceGroupName parameter cannot be null"
        exit
    fi

    if [[ -z $location ]]; then
        echo "The location parameter cannot be null"
        exit
    fi

    # Check if the resource group already exists
    echo "Checking if [$resourceGroupName] resource group actually exists in the [$subscriptionName] subscription..."
    az group show --name "$resourceGroupName" &>/dev/null

    if [[ $? != 0 ]]; then
        echo "No [$resourceGroupName] resource group actually exists in the [$subscriptionName] subscription"
        echo "Creating [$resourceGroupName] resource group in the [$subscriptionName] subscription..."

        # Create the resource group
        az group create \
            --name "$resourceGroupName" \
            --location "$location" 1>/dev/null

        if [[ $? != 0 ]]; then
            echo "[$resourceGroupName] resource group successfully created in the [$subscriptionName] subscription"
        else
            echo "Failed to create [$resourceGroupName] resource group in the [$subscriptionName] subscription"
            exit
        fi
    else
        echo "[$resourceGroupName] resource group already exists in the [$subscriptionName] subscription"
    fi
}

# Function to validate an ARM template
validateTemplate() {
    local resourceGroupName=$1
    local template=$2
    local parameters=$3
    local arguments=$4

    # Parameters validation
    if [[ -z $resourceGroupName ]]; then
        echo "The resource group name parameter cannot be null"
    fi

    if [[ -z $template ]]; then
        echo "The template parameter cannot be null"
    fi

    if [[ -z $parameters ]]; then
        echo "The parameters parameter cannot be null"
    fi

    if [[ -z $arguments ]]; then
        echo "The arguments parameter cannot be null"
    fi

    echo "Validating [$template] ARM template against the [$subscriptionName] subscription..."

    if [[ -z $arguments ]]; then
        error=$(az deployment group validate \
            --resource-group "$resourceGroupName" \
            --template-file "$template" \
            --parameters "$parameters" \
            --query error \
            --output json)
    else
        error=$(az deployment group validate \
            --resource-group "$resourceGroupName" \
            --template-file "$template" \
            --parameters "$parameters" \
            --arguments $arguments \
            --query error \
            --output json)
    fi

    if [[ -z $error ]]; then
        echo "[$template] ARM template successfully validated against the [$subscriptionName] subscription"
    else
        echo "Failed to validate the [$template] ARM template against the [$subscriptionName] subscription"
        echo "$error"
        exit 1
    fi
}

# Function to deploy an ARM template
deployTemplate() {
    local resourceGroupName=$1
    local template=$2
    local parameters=$3
    local arguments=$4

    # Parameters validation
    if [[ -z $resourceGroupName ]]; then
        echo "The resource group name parameter cannot be null"
        exit
    fi

    if [[ -z $template ]]; then
        echo "The template parameter cannot be null"
        exit
    fi

    if [[ -z $parameters ]]; then
        echo "The parameters parameter cannot be null"
        exit
    fi

    # Deploy the ARM template
    echo "Deploying [$template$] ARM template to the [$subscriptionName] subscription..."

    if [[ -z $arguments ]]; then
        az deployment group create \
            --resource-group $resourceGroupName \
            --template-file $template \
            --parameters $parameters 1>/dev/null
    else
        az deployment group create \
            --resource-group $resourceGroupName \
            --template-file $template \
            --parameters $parameters \
            --parameters $arguments 1>/dev/null
    fi

    if [[ $? == 0 ]]; then
        echo "[$template$] ARM template successfully provisioned to the [$subscriptionName] subscription"
    else
        echo "Failed to provision the [$template$] ARM template to the [$subscriptionName] subscription"
        exit -1
    fi
}

# Create Resource Group
createResourceGroup "$resourceGroupName" "$location"

# Check if the Log Analytics workspace already exists
echo "Checking if [$workspaceName] Log Analytics workspace actually exists in the [$subscriptionName] subscription..."
az monitor log-analytics workspace show \
    --resource-group "$resourceGroupName" \
    --workspace-name "$workspaceName" &>/dev/null

if [[ $? != 0 ]]; then
    echo "No [$workspaceName] Log Analytics workspace actually exists in the [$subscriptionName] subscription"
    echo "Creating [$workspaceName] Log Analytics workspace in the [$subscriptionName] subscription..."

    # Deploy Log Analytics via ARM template
    deployTemplate \
        "$resourceGroupName" \
        "$template" \
        "$parameters" \
        "workspaceName=$workspaceName workspaceSku=$workspaceSku location=$location"

    # Create the Log Analytics workspace
    if [[ $? != 0 ]]; then
        echo "[$workspaceName] Log Analytics workspace successfully created in the [$subscriptionName] subscription."
    else
        echo "Failed to create [$workspaceName] Log Analytics workspace in the [$subscriptionName] subscription."
        exit
    fi
else
    echo "[$workspaceName] Log Analytics workspace already exists in the [$subscriptionName] subscription."
fi

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
