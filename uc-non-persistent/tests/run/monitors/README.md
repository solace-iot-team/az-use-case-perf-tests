# Monitors

> :warning: **UNDER CONSTRUCTION**


Gathers stats:

 * Broker Message VPN Stats
 * SDKPerf Latency Stats
 * PING between latency node and broker node

### Customize

````bash
vi ../../vars/monitor.vars.yml

````

### Run all monitors

_**Note: Instead of passing the infrastrucure as an argument to the scripts, you can set env var `UC_NON_PERSISTENT_INFRASTRUCTURE`.**_

````bash
./run.monitor.sh {cloud_provider}.{infrastructure-id}
# example: ./run.monitor.sh azure.infra1-standalone
````
Results:
- interim: run.current
- moved to run.{timestamp} after completion
- link: run.latest points to latest run

#### Run VPN Stats only
````bash
./run.monitor.vpn-stats.sh {cloud_provider}.{infrastructure-id}
````
#### Run Latency only
````bash
./run.monitor.latency.sh {cloud_provider}.{infrastructure-id}
````
#### Run Ping only
````bash
./run.monitor.ping.sh {cloud_provider}.{infrastructure-id}
````
### Run Broker Node Latency only
Running SDKPerf on the same VM as the Broker Docker container is running.
Eliminates any network.

````bash
./run.monitor.brokernode.latency.sh {cloud_provider}.{infrastructure-id}
````

### Results

* Directory: **{root}/test-results/stats**
* Directory for each test run: **{root}/test-results/stats/run.{UTC-timestamp}**
* Within each directory:
  - latency-stats.{timestamp}.json
  - latency-brokernode-stats.{timestamp}.json
  - vpn-stats.{timestamp}.json
  - ping-stats.{timestamp}.json
  - run.meta.json

---
The End.
