# Monitor

Gathers stats during a load test run.

 * Broker Message VPN Stats
 * SDKPerf Latency Stats

### Customize

````bash
vi ./vars/monitor.vars.yml

````

### Run

````bash
./run.monitor.sh
# starts vpn stats & latency scripts in the background
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

### Results

* Directory: **{root}/test-results/stats**
* Directory for each test run: **{root}/test-results/stats/run.{UTC-timestamp}**
* Within each directory:
  - latency-stats.{timestamp}.log
  - vpn-stats.{timestamp}.log
  - run.meta.json

---
The End.
