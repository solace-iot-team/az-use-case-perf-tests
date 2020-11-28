# Release Notes

## Version: 0.7.5
Release Purpose: Azure VM Networking Optimizations

_Note: Optimizations only apply to Azure._

**uc-non-persistent/infrastructure/standalone/azure**
* **az-variables.tf**
  - new variables:
    - "source_image_reference_openlogic_centos_sku": "8_2" or "7.7",
    - "apply_kernel_optimizations": false | true
    - "apply_mellanox_vma": false | true
    - examples:
      - **auto-run/azure.tp-sml.tfvars.json**


**uc-non-persistent/infrastructure/standalone/bootstrap**
* new: **vars/optimization.vars.yml**
  - entries for kernel/OS version and mellanox/OS version
* new: **bootstrap.opts.kernel.playbook.yml**
  - applies kernel optimizations to all vms
* new: **bootstrap.opts.mellanox.playbook.yml**
  - applies mellanox vma driver

**analytics**
* **analytics/run-analysis.ipynb**
  - includes optimization settings
  - includes image references per node

## Version: 0.7.4
Release Purpose: Test Spec Schema & tp-sml

**Breaking Change:**
* **uc-non-persistent/tests/_run.sh**
  * env var: LOG_DIR
    - new required env var, directory for logs
    - example: **uc-uc_non_persistent/tests/auto-run/run.tp-sml.fg.sh**
    ````bash
    export LOG_DIR=$scriptDir/logs
    ````

**tp-sml & tp-003:**
* **uc-non-persistent/infrastructure/standalone/auto-run**
  * **azure.tp-sml.tfvars.json**, **aws.tp-sml.tfvars.json**
    - infrastructure specs for running tp-sml
  * **run.apply.tp-sml.fg.sh**, **run.destroy.tp-sml.fg.sh**
    - standup & destroy infrastructures for tp-sml
  * **azure.tp-003.tfvars.json**, **aws.tp-003.tfvars.json**
    - infrastructure specs for running tp-003
  * **run.apply.tp-003.fg.sh**, **run.destroy.tp-003.fg.sh**
    - standup & destroy infrastructures for tp-003
* **uc-non-persistent/tests/auto-run**
  * **tp-sml.test.spec.yml**
    - the tp-sml test spec
  * **run.tp-sml.fg.sh**
    - run tp-sml spec
  * **validate.tp-sml.fg.sh**
    - validate the tp-sml spec only
* **.github/workflows/prod-uc-non-persistent.yml**
  * added workflow input: test spec id
* **analytics/auto-run**
  * **run.uc-uc_non_persistent.tp-003.fg.sh**
    - run analytics against tp-003 results
  * **run.uc-uc_non_persistent.tp-sml.fg.sh**
    - run analytics against tp-sml results


**Workflows:**
* ADDED: downloading logs recursively:
  - sftp -p ==> sftp -p -r
* ADDED: **.github/ssh-connect-controller.sh**
  - ISSUE: ssh connection refused to newly started controller
  - try multiple times with a wait in between
* **.github/bootstrap-controller.sh**
  - upgrade jsonschema to latest version
  - ubuntu:
  ````bash
  sudo -H python3 -m pip install --upgrade jsonschema
  ````
* **shared-setup**
  - download into results/uc-non-persistent/shared-setup

**Validation of Test Spec against Schema**

Validates test specs and generated run specs against a json schema.
* **New Environment Variables**
  - optional, default=False
  ````bash
  export GENERATE_ONLY="True"
  export VALIDATE_SPECS="True"
  ````
* **Installation on Mac:**
  ````bash
  pip3 install --upgrade jsonschema
  jsonschema -h
  pip3 show jsonschema
  ````
* **Installation on Ubuntu 18**
  ````bash
  sudo -H python3 -m pip install --upgrade jsonschema
  jsonschema -h
  pip3 show jsonschema
  ````


## Version: 0.7.3
Release Purpose: Maintenance Analytics

**BUG Fixes:**
* **analytics**
  - bugs fixed when load not included in test

**New:**
* **analytics**
  - added release version to header

## Version: 0.7.2
Release Purpose: Maintenance & Analytics

**BUG Fixes:**
* **analytics**
  - ping stats converted to micro seconds

**New:**
* **uc-non-persistent/infrastructure/standalone/bootstrap/vars/bootstrap.vars.yml**
  - added facility to set sysctl_conf variables for vms (sysctl_conf.net.ipv4.tcp_mem: "669723 892967 1439446")

* **analytics**
  - added more detailed analytics on consumer client connections
  - generates a header & links
  - added histograms from raw latency metrics

## Version: 0.7.1
Release Purpose: Maintenance & Prep for Further Analysis

**_Note: This release contains breaking changes._**

**Infrastructure:**

* **infrastructure/standalone/_run.destroy.sh**
  - calls terraform destroy for each infrastructure up to 5 times with 5 minutes delay in case destroy was unsuccessful
    - workaround for issue: terraform destroy not working the first time

**Tests:**

* **tests/auto-run/template.{spec-id}.test.spec.yml**
  - **_breaking changes_**
  - changed schema:
    - deleted:
      - monitors.vpn_stats.include - now set to true by default
      - monitors.latency.sdkperf_node_to_broker.include
      - monitors.latency.broker_node_to_broker.include
    - added:
      - monitors.latency.include_latency_node_to_broker
      - monitors.latency.include_broker_node_to_broker
* **test-results/stats/{infrastructure-id}/{run-id}/vpn-stats.{ts}.json**
  - added collection of tcp stats from broker per client connection
  - `client_connections.client_connection_details`
    - contains tcp stats per client connection from broker
  - `client_connections.clients`
    - contains message stats per client from broker
* **tests/run/_run.sh**
  - new test teardown sequence
    - stop publishers
    - gather final vpn stats including client tcp connection stats
    - stop consumers
    - uses two new scripts: `tests/run/load/_stop.load.publishers.sh` and `test/run/load/_stop.load.consumers.sh`
* **tests/run/_run.post-load.sh**
  - new script, runs after load publishers & consumers are terminated
  - retrieves final broker statistics for accurate message tally
    - reaults in 1 additional `vpn-stats.{ts}.json file`
  - uses:
    - tests/run/monitors/broker.vpn-stats.last.playbook.yml
* **tests/auto-run/tp-003.test.spec.yml**
  - soak test spec
  - used by `.github/workflows/prod-uc-non-persistent.yml`


## Version: 0.7.0
Release Purpose: Consumer Deployment Strategy

**_Note: This release contains breaking changes._**

**Infrastructure:**

* **uc-non-persistent/infrastructure/_run.apply.sh**
  - mandatory removal of `terraform taint` for bootstrap resource
    - now solved in terraform script itself with `always_run = "${timestamp()}"`
* **uc-non-persistent/infrastructure/{aws|azure}**
  - bootstrap.tf
    - triggers always
    - includes a bootstrap destroy provisioner
    - _note: do not use terraform taint command any more!_
* **uc-non-persistent/infrastructure/{aws|azure}/{aws-variables.tf|az-variables.tf}**
  - added more variables for various types of nodes: publisher, consumer, latency
* **uc-non-persistent/infrastructure/bootstrap/_run.bootstrap.destroy.sh & bootstrap.destroy.playbook.yml**
  - called from terraform script `{aws|az}-bootstrap.tf`
    - cleans up bootstrap, manifest file in shared-setup
* **uc-non-persistent/shared-setup**
  - new file: `{infrastructureId}.broker.manifest.json`
    - used for reporting, contains the broker version

**Tests:**
* **uc-non-persistent/tests/auto-run/template.{spec-id}.test.spec.yml**
  - removed `lpm` from configuration (it is always set to true now)
  - added: `load.subscribe.consumer_distribution_strategy=[round_robin | carbon_copy ]`
* **uc-non-persistent/test-results/stats**:
  - `meta.json` contains the broker image used
* **uc-non-persistent/tests/auto-run/tp-001.test.spec.yml**
  - example implementation of test case tp-001
* **uc-non-persistent/tests/auto-run/tp-002.test.spec.yml**
  - example implementation of test case tp-002

**Analytics:**
* introduced check for zero-message-loss
* added bar chart of consumer/node distribution and total message numbers received
* various minor changes and fixes


## Version: 0.6.0
Release Purpose: Analytics & Report Generation

#### New
**analytics module**
* based on jupyter notebooks
* **analytics/notebooks/run-analysis.ipynb**
  - production notebook to analyze a single run and generate a report
* **analytics/auto-run**
  - sample script to analyze and generate html reports for all runs in **test-results/stats/{infrastructure-id}** folders
* **test-results/analysis**
  - contains 1 html report file per run analyzed

#### Changes

* **uc-non-persistent/test-results/stats/{infrastructure-id}/{run-id}/meta.json**
  - added inventory used for reporting on runs
  - added region to _env_ section
* **uc-non-persistent/infrastructure/standalone/{aws|azure}/{terraform-scripts}**
  - added region info to _*.env_ output file

**_Note: These changes require a re-run of the tests for the analytics to work._**

* **uc-non-persistent/infrastructure/standalone/_run.destroy-all.sh**
  - destroys each infrastructure sequentially instead of in parallel (issues experienced with parallel destroy)

#### Known Issues
* **uc-non-persistent/infrastructure/standalone/_run.destroy-al.sh**
  - destroy azure infrastructures results almost always in an error
  - terraform errro output examples:


````code
  [1m[31mError: [0m[0m[1mError waiting for update of Network Interface "test1-sdkperf-nic-1" (Resource Group "test1-sdkperf_resgrp"): Code="OperationNotAllowed" Message="Operation 'startTenantUpdate' is not allowed on VM 'test1-sdkperf-node-1' since the VM is marked for deletion. You can only retry the Delete operation (or wait for an ongoing one to complete)." Details=[][0m
````

````code
  ESC[1mESC[31mError: ESC[0mESC[0mESC[1mError deleting Network Security Group "2-auto-sdkperf_secgrp" (Resource Group "2-auto-sdkperf_resgrp"): network.SecurityGroupsClient#Delete: Failure sending request: StatusCode=400 -- Original Error: Code="NetworkSecurityGroupOldReferencesNotCleanedUp" Message="Network security group 2-auto-sdkperf_secgrp cannot be deleted because old references for the following Nics: (\n/subscriptions/837ffe8b-4d6f-4611-908e-bbfd4106a53a/resourceGroups/2-auto-sdkperf_resgrp/providers/Microsoft.Network/networkSecurityGroups/2-auto-sdkperf_secgrp:/subscriptions/837ffe8b-4d6f-4611-908e-bbfd4106a53a/resourceGroups/2-auto-sdkperf_resgrp/providers/Microsoft.Network/networkInterfaces/2-auto-sdkperf-nic-1) and Subnet: (\n/subscriptions/837ffe8b-4d6f-4611-908e-bbfd4106a53a/resourceGroups/2-auto-sdkperf_resgrp/providers/Microsoft.Network/networkSecurityGroups/2-auto-sdkperf_secgrp:) have not been released yet." Details=[]ESC[0m

  ESC[0mESC[0mESC[0m
  >>> ERROR - 1 - _run.destroy.sh - executing terraform
````



## Version: 0.5.3
Release Purpose: Maintenance Load

**load startup fix**
  * issue: sdkperf randomly not starting correctly on newly stood up infrastructure
  * solution: retry (max 10 times) on start-up failure

## Version: 0.5.2
Release Purpose: Auto-generated & adjustable Topics

> :warning: **BREAKING CHANGES**

**Test Spec**
  * **uc-non-persistent/tests/auto-run**
    - _**(breaking changes)**_
    - 1_auto.test.spec.yml
    - template.{spec-id}.test.spec.yml
    - format changes to support auto generated & adjustable number of topics for publishers & consumers (load only) to test impact on performance
  * **uc-non-persistent/infrastructure/standalone/azure & aws**
    - added new security rules to allow plain MQTT & websocket traffic
    - for testing purposes only
    - use e.g. MQTT Explorer to see all the topics used by load test

## Version: 0.5.1
Release Purpose: Automated Testing

**Github Workflow**
  * **.github/workflows**
    - test-uc-non-persistent.yml
      - runs on: pull_request, release, weekly schedule
      - bootstraps external controller vm in azure
      - runs
        - **uc-non-persistent/infrastructure/standalone/.test/run.apply.fg.sh**
        - **uc-non-persistent/tests/.test/run.fg.sh**
        - **uc-non-persistent/infrastructure/standalone/.test/run.destroy.fg.sh**
      - archives results
  * [see here for pre-requisites](.github/WorkflowsReadme.md)

**FIXES**
  * fixes to log file directory for infrastructure bootstrap
    - bootstrap scripts now logs into same directory as other _run.apply_ scripts
  * tainting of trigger_bootstrap resource
    - added to __run.apply.sh_
  * terrform: azure/az-sa-sdkperf-nodes and az-sa-sol-broker-nodes
    - resource "azurerm_network_interface_security_group_association" "sdkperf-nodes-secgrp_association"
      - added dependency on nic interfaces - should resolve error of nic not being ready


## Version: 0.5.0
Release Purpose: Auto Runs: Multi-Test & Infrastructure

**RESTRUCTURED REPOSITORY**
  * **created**
    - uc-non-persistent/infrastructure
      - contains all infrastructure related code
    - uc-non-persistent/tests
      - contains all testing related code
  * **removed:**
    - uc-non-persistent/ansible
    - uc-non-persistent/terraform

**NEW FEATURES**
  * **uc-non-persistent/tests**
    - test spec based test run framework
    - supports multiple runs based on variations across any number of provisioned infrastructures
  * **uc-non-persistent/tests/auto-run**
    - sample scripts and test specs for workflow triggered testing
  * **uc-non-persistent/infrastructure/standalone/auto-run**
    - sample scripts and infrastructure specs for workflow triggered standup/destroy

**FIXES:**
  * **terraform**
    - fixed sdkperf nodes dynamic ip address issue

## Version: 0.4.3
Release Purpose: Introduce Latency per Message Metric

* **vars/monitor.vars.yml**
  - added lpm flag to latency parameters
* **monitor/latency and monitor/brokernode-latency**
  - output contains latency_per_message_in_usec - array of individual message latencies.
* **test-results/stats**
  - stats files renamed:
    - latency-brokernode-stats.{rund-id}.json ==> latency_brokernode_stats.{run-id}.json
    - latency-stats.{run-id}.json ==> latency_stats.{run-id}.json
    - ping-stats{run-id}.json ==> ping_stats.{run-id}.json
    - vpn-stats{run-id}.json ==> vpn_stats.{run-id}.json
    - run.meta.json ==> meta.{run-id}.json
* **tests/abort.tests.sh**
  - added: call to abort running tests

## Version: 0.4.2
Release Purpose: Infrastructure Bootstrap & Controller Create/Delete

* **terraform/{cloud-provider}/standalone**
  - added: shared-setup/{cloud_provider}.{infrastructure-id}.env.json
    - contains proximity placement group
  - added: generation of shared-setup/{cloud_provider}.{infrastructure-id}.inventory.json
    - this is the ansible inventory
  - added: run ansible/bootstrap/run.bootstrap.sh
    - at the end of the provisioning process
* **terraform/azure/standalone**
  - added: zone parameter
    - sdkperf & broker node
    - az-variables.template
* **infrastructure/controller/azure**
  - create controller VM in Azure using ARM template
* **bin/pubsub**
  - added directory to hold copy or link to solace docker image
* **uc-non-persistent/ansible/bootstrap**
  - extracts manifest and reads the image:tag info automatically. no need for manual adjustment in var files any more.

## Version: 0.4.1
Release Purpose: Maintenance release: logging & error handling

* **logging**
  - scripts `run.tests.sh` and `monitor/run.monitor.sh` create log files
* **error handling**
  - in case a test/monitor fails, the entire run is stopped
  - log files are searched for errors and
    - `ERROR.log` created with file / error details
    - `SUCCESS.log` created, empty
* **log files included in results**
  - each run has a sub-directory: `logs`

## Version: 0.4.0
Release Purpose: Major release to incorporate multiple infrastrucures in potentially different cloud providers.

* **added aws infrastructure support via terraform**
  - all scripts receive {cloud-provider}.{infrastructure-id} as parameter or through env var `UC_NON_PERSISTENT_INFRASTRUCTURE`
* **restructured directories**
  - ansible/bootstrap
  - ansible/tests
    - load
    - monitor
* **aligned timing of monitoring results**
  - results are now within 1 minute buckets, aligned.

## Version: 0.3.2
Release Purpose: New monitor: SDKPerf running on broker node.

* monitors
  - run.monitor.latency-broker-node.sh
    - integrated into overall test scripts
    - generates new result file

## Version: 0.3.1
Release Purpose: Optimization of Azure Resources

* terraform
  - added azurerm_proximity_placement_group so all nodes are co-located
  - added enable_accelerated_networking to network interface
* misc
  - updated ansible & ansible-solace install instructions

## Version: 0.3.0
Release Purpose: Correlation of Results

* Result JSON files:
  - changed 'timestamp' to 'sample_start_timestamp'
  - added 'sample_num': the sample number in the test
  - added 'sample_corr_id': composed of 'run_id'+'sample_num' - to correlate results
  - ping
    - results have 'ping' in JSON path. allows for better distinguishing of joined tables in Kusto
  - latency
    - results have 'latency_node' in the metrics path - to distinguish from 'broker_node' latency

## Version: 0.2.0
Release Purpose: JSON Output for Monitoring Results

* Tooling:
  - yq
    - added use of yq to parse yaml files in bash
    - install: `pip3 install yq`
* PING results:
  - added post processing of ping log to json format
* Latency results:
  - added post processing of sdkperf output to json format
* VPN stats results:
  - added post processing of vpn stats to include timestamp
* test results:
  - current run in `run.current`
  - completed run in `run.{end-timestamp}`
    - and link `run.latest` points to completed run
* run all tests
  - script: `ansible/run.tests.sh`
    - starts load, runs monitors, stops load
* added initial Azure Data Explorer integration
  - uc-common/infrastructure/az-data-explorer
  - upload results to blob, import to Kusto, create timeseries graphs


---
The End.
