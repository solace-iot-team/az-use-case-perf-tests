#!/bin/bash
# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# ---------------------------------------------------------------------------------------------

clear
scriptName=$(basename $(test -L "$0" && readlink "$0" || echo "$0"));
scriptDir=$(cd $(dirname "$0") && pwd);

############################################################################################################################
# Functions
function assertFile() {
  local file=$1
  if [[ ! -f "$file" ]]; then
    echo ">>> ERR: file='$file' does not exist. aborting." > /dev/tty
    echo > /dev/tty
    return 1;
  fi
  echo $file
  return 0
}
# End Functions
############################################################################################################################
echo
echo "##############################################################################################################"
echo "# Generate inventory"
echo "# "

############################################################################################################################
# Settings

  brokerNodesFile=$(assertFile "$scriptDir/../../shared-setup/broker-nodes.json") || exit
  sdkPerfNodesFile=$(assertFile "$scriptDir/../../shared-setup/sdkperf-nodes.json") || exit
  targetInventoryFile="$scriptDir/inventory.json"
  srcInventoryTemplateFile="$scriptDir/inventory.template.json"

############################################################################################################################
# Generate

  brokerNodesJson=$( cat $brokerNodesFile | jq -r . )
  sdkPerfNodesJson=$( cat $sdkPerfNodesFile | jq -r . )
  inventoryJson=$( cat $srcInventoryTemplateFile | jq -r . )

  # broker node info
  export adminUser=$( echo $brokerNodesJson | jq -r ".broker_nodes[0].admin_username")
  export publicIp=$( echo $brokerNodesJson | jq -r ".broker_nodes[0].public_ip")
  export privateIp=$( echo $brokerNodesJson | jq -r ".broker_nodes[0].private_ip")

  inventoryJson=$( echo $inventoryJson | jq -r '.all.vars.broker_pubsub.public_ip_address=env.publicIp' )
  inventoryJson=$( echo $inventoryJson | jq -r '.all.vars.broker_pubsub.private_ip_address=env.privateIp' )

  inventoryJson=$( echo $inventoryJson | jq -r '.all.hosts.broker_centos.ansible_host=env.publicIp' )
  inventoryJson=$( echo $inventoryJson | jq -r '.all.hosts.broker_centos.ansible_user=env.adminUser' )

  inventoryJson=$( echo $inventoryJson | jq -r '.all.hosts.broker_pubsub.sempv2_host=env.publicIp' )

  inventoryJson=$( echo $inventoryJson | jq -r '.all.hosts.broker_pubsub.sempv2_host=env.publicIp' )

  # sdkperf nodes info
  # publisher
  export adminUser=$( echo $sdkPerfNodesJson | jq -r ".sdkperf_nodes[0].admin_username")
  export name=$( echo $sdkPerfNodesJson | jq -r ".sdkperf_nodes[0].name")
  export publicIp=$( echo $sdkPerfNodesJson | jq -r ".sdkperf_nodes[0].public_ip")
  inventoryJson=$( echo $inventoryJson | jq -r '.sdkperf_publishers.hosts.sdkperf_publisher_vm_0.ansible_host=env.publicIp' )
  inventoryJson=$( echo $inventoryJson | jq -r '.sdkperf_publishers.hosts.sdkperf_publisher_vm_0.ansible_user=env.adminUser' )
  inventoryJson=$( echo $inventoryJson | jq -r '.sdkperf_publishers.hosts.sdkperf_publisher_vm_0.az_vm_name=env.name' )

  # consumer 1
  export adminUser=$( echo $sdkPerfNodesJson | jq -r ".sdkperf_nodes[1].admin_username")
  export name=$( echo $sdkPerfNodesJson | jq -r ".sdkperf_nodes[1].name")
  export publicIp=$( echo $sdkPerfNodesJson | jq -r ".sdkperf_nodes[1].public_ip")
  inventoryJson=$( echo $inventoryJson | jq -r '.sdkperf_consumers.hosts.sdkperf_consumer_vm_1.ansible_host=env.publicIp' )
  inventoryJson=$( echo $inventoryJson | jq -r '.sdkperf_consumers.hosts.sdkperf_consumer_vm_1.ansible_user=env.adminUser' )
  inventoryJson=$( echo $inventoryJson | jq -r '.sdkperf_consumers.hosts.sdkperf_consumer_vm_1.az_vm_name=env.name' )

  # consumer 2
  export adminUser=$( echo $sdkPerfNodesJson | jq -r ".sdkperf_nodes[2].admin_username")
  export name=$( echo $sdkPerfNodesJson | jq -r ".sdkperf_nodes[2].name")
  export publicIp=$( echo $sdkPerfNodesJson | jq -r ".sdkperf_nodes[2].public_ip")
  inventoryJson=$( echo $inventoryJson | jq -r '.sdkperf_consumers.hosts.sdkperf_consumer_vm_2.ansible_host=env.publicIp' )
  inventoryJson=$( echo $inventoryJson | jq -r '.sdkperf_consumers.hosts.sdkperf_consumer_vm_2.ansible_user=env.adminUser' )
  inventoryJson=$( echo $inventoryJson | jq -r '.sdkperf_consumers.hosts.sdkperf_consumer_vm_2.az_vm_name=env.name' )

  # latency
  export adminUser=$( echo $sdkPerfNodesJson | jq -r ".sdkperf_nodes[3].admin_username")
  export name=$( echo $sdkPerfNodesJson | jq -r ".sdkperf_nodes[3].name")
  export publicIp=$( echo $sdkPerfNodesJson | jq -r ".sdkperf_nodes[3].public_ip")
  inventoryJson=$( echo $inventoryJson | jq -r '.sdkperf_latency.hosts.sdkperf_latency_vm_3.ansible_host=env.publicIp' )
  inventoryJson=$( echo $inventoryJson | jq -r '.sdkperf_latency.hosts.sdkperf_latency_vm_3.ansible_user=env.adminUser' )
  inventoryJson=$( echo $inventoryJson | jq -r '.sdkperf_latency.hosts.sdkperf_latency_vm_3.az_vm_name=env.name' )

  echo $inventoryJson | jq . > $targetInventoryFile

echo "# generated: $targetInventoryFile"
jq . $targetInventoryFile


## The End.
#
