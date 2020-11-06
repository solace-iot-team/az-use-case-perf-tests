# Release Notes

## Version: 0.6.0
Release Purpose: Analytics & Report Generation

#### New
**analytics**
* based on jupyter notebooks
* **analytics/notebooks/run-analysis.ipynb**
  - production notebook to analyze a single run and generate a report
* **analytics/auto-run**
  - sample script to analyze and generate html reports for all runs in **test-results/stats/{infrastructure-id}** folders
* **test-results/analysis**
  - contains 1 html report file per run analyzed

#### Changes

**meta.json**
  * added inventory used for reporting on runs

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
