# Release Notes

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
