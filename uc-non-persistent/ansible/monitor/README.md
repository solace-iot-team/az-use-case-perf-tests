# Monitor

Gathers stats during a load test run.

 * Broker Message VPN Stats
 * SDKPerf Latency Stats
 * PING between latency node and broker node

### Customize

````bash
vi ./vars/monitor.vars.yml

````

### Run

````bash
# start it in the background
./run.monitor.sh &
  # starts vpn stats & latency scripts in the background

# get the pids
ps -ef | grep run.monitor

# log files:
ls *.log

````
Results:
- interim: run.latest
- moved to run.{timestamp} after completion

#### Run VPN Stats only
````bash
./run.monitor.vpn-stats.sh
````
#### Run Latency only
````bash
./run.monitor.latency.sh
````
#### Run Ping only
````bash
./run.monitor.ping.sh
````

### Run Broker Node Latency
Running SDKPerf on the same VM as the Broker Docker container is running.
Eliminates any network.

Run with/without load and latency monitor.

````bash
./run.monitor.brokernode.latency.sh
````

To stop it again:
````bash
./stop.monitor.brokernode.latency.sh
````

### Results

* Directory: **{root}/test-results/stats**
* Directory for each test run: **{root}/test-results/stats/run.{UTC-timestamp}**
* Within each directory:
  - latency-stats.{timestamp}.log
  - vpn-stats.{timestamp}.log
  - ping-stats.{timestamp}.log
  - run.meta.json

---
The End.
