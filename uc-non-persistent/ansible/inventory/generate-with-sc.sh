#!/bin/bash
# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# ---------------------------------------------------------------------------------------------

clear

############################################################################################################################
echo
echo "##############################################################################################################"
echo "# Generate inventory"
echo "# "

############################################################################################################################
# prepare
  scriptName=$(basename $(test -L "$0" && readlink "$0" || echo "$0"));
  scriptDir=$(cd $(dirname "$0") && pwd);
  source ./.lib/functions.sh
  projectHome=${scriptDir%%/ansible/*}

############################################################################################################################
# Settings

  sharedSetupDir="$projectHome/shared-setup"
    [ ! -d $sharedSetupDir ] && (echo ">>> ERROR: directory $sharedSetupDir DOES NOT exists."; exit)
  brokerNodesFile=$(assertFile "$sharedSetupDir/broker-nodes.json") || exit
  sdkPerfNodesFile=$(assertFile "$sharedSetupDir/sdkperf-nodes.json") || exit
  targetInventoryFile="$scriptDir/inventory.json"
  srcInventoryTemplateFile="$scriptDir/inventory.template.json"
  solaceCloudInventoryFile="$sharedSetupDir/inventory.sc-service.az_use_case_perf_tests.json"

############################################################################################################################
# User select which broker

  if [[ -f $solaceCloudInventoryFile ]]; then
    invalid=1
    until [ $invalid -eq 0 ]; do
      echo
      echo "(1): Standalone Broker in VM"
      echo "(2): Solace Cloud Broker"
      echo
      read -p " >> Choose which broker to run tests against: " choice
      if [[ ! "$choice" =~ ^[1-2]+$ ]]; then
        echo " >> choose {1|2}, your choice:$choice is not valid."
      else
        invalid=0
      fi
    done
  fi
  # default
  chosenBroker="standalone-broker"
  if [[ "$choice" -eq 2 ]]; then chosenBroker="solace-cloud-broker"; fi

  if [[ "$chosenBroker" == "solace-cloud-broker" ]]; then
    solaceCloudInventoryFile=$(assertFile "$sharedSetupDir/inventory.sc-service.az_use_case_perf_tests.json") || exit
    solaceCloudClientConnectionDetailsFile=$(assertFile "$sharedSetupDir/az_use_case_perf_tests.client_connection_details.json") || exit
  fi

############################################################################################################################
# Generate

  if [[ "$chosenBroker" == "solace-cloud-broker" ]]; then
    solaceCloudInventoryJson=$( cat $solaceCloudInventoryFile | jq -r .)
    solaceCloudClientConnectionDetailsJson=$( cat $solaceCloudClientConnectionDetailsFile | jq -r .)
  fi
  brokerNodesJson=$( cat $brokerNodesFile | jq -r . )
  sdkPerfNodesJson=$( cat $sdkPerfNodesFile | jq -r . )
  inventoryJson=$( cat $srcInventoryTemplateFile | jq -r . )

  # broker node info
    export adminUser=$( echo $brokerNodesJson | jq -r ".broker_nodes[0].admin_username")
    export publicIp=$( echo $brokerNodesJson | jq -r ".broker_nodes[0].public_ip")
    export privateIp=$( echo $brokerNodesJson | jq -r ".broker_nodes[0].private_ip")
    inventoryJson=$( echo $inventoryJson | jq -r '.all.hosts.broker_centos.ansible_host=env.publicIp' )
    inventoryJson=$( echo $inventoryJson | jq -r '.all.hosts.broker_centos.ansible_user=env.adminUser' )
    if [[ "$chosenBroker" == "standalone-broker" ]]; then
      inventoryJson=$( echo $inventoryJson | jq -r '.all.vars.broker_pubsub.public_ip_address=env.publicIp' )
      inventoryJson=$( echo $inventoryJson | jq -r '.all.vars.broker_pubsub.private_ip_address=env.privateIp' )
      inventoryJson=$( echo $inventoryJson | jq -r '.all.hosts.broker_pubsub.sempv2_host=env.publicIp' )
    fi
    if [[ "$chosenBroker" == "solace-cloud-broker" ]]; then
      export sempv2Host=$( echo $solaceCloudInventoryJson | jq -r ".all.hosts.az_use_case_perf_tests.sempv2_host")
      export sempv2Port=$( echo $solaceCloudInventoryJson | jq -r ".all.hosts.az_use_case_perf_tests.sempv2_port")
      export apiToken=$( echo $solaceCloudInventoryJson | jq -r ".all.hosts.az_use_case_perf_tests.solace_cloud_api_token")
      export serviceId=$( echo $solaceCloudInventoryJson | jq -r ".all.hosts.az_use_case_perf_tests.solace_cloud_service_id")
      export sempv2AdminUser=$( echo $solaceCloudInventoryJson | jq -r ".all.hosts.az_use_case_perf_tests.sempv2_username")
      export sempv2AdminPwd=$( echo $solaceCloudInventoryJson | jq -r ".all.hosts.az_use_case_perf_tests.sempv2_password")
      export meta=$( echo $solaceCloudInventoryJson | jq ".all.hosts.az_use_case_perf_tests.meta")

      inventoryJson=$( echo $inventoryJson | jq -r '.all.vars.broker_pubsub.public_ip_address=env.sempv2Host' )
      inventoryJson=$( echo $inventoryJson | jq -r '.all.vars.broker_pubsub.private_ip_address=env.sempv2Host' )

      inventoryJson=$( echo $inventoryJson | jq -r '.all.hosts.broker_pubsub.sempv2_host=env.sempv2Host' )
      inventoryJson=$( echo $inventoryJson | jq -r '.all.hosts.broker_pubsub.sempv2_port=env.sempv2Port' )
      inventoryJson=$( echo $inventoryJson | jq -r '.all.hosts.broker_pubsub.sempv2_is_secure_connection=true' )
      inventoryJson=$( echo $inventoryJson | jq -r '.all.hosts.broker_pubsub.sempv2_username=env.sempv2AdminUser' )
      inventoryJson=$( echo $inventoryJson | jq -r '.all.hosts.broker_pubsub.sempv2_password=env.sempv2AdminPwd' )
      inventoryJson=$( echo $inventoryJson | jq -r '.all.hosts.broker_pubsub.solace_cloud_api_token=env.apiToken' )
      inventoryJson=$( echo $inventoryJson | jq -r '.all.hosts.broker_pubsub.solace_cloud_service_id=env.serviceId' )
      inventoryJson=$( echo $inventoryJson | jq '.all.hosts.broker_pubsub.meta += (env.meta | fromjson )' )

    fi

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
