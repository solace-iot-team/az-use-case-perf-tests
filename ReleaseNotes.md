# Release Notes

## Version: 0.4.2
Release Purpose: Controller Create/Delete

* **terraform/azure**
  - added: shared-setup/azure.{infrastructure-id}.env.json
    - contains proximity placement group
* 

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
