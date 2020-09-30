# Release Notes

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
