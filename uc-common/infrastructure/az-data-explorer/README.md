# Azure Data Explorer

## Setup

````bash
cd vars
cp template.adx.vars.json adx.vars.json
vi adx.vars.json
 # change values
cd ..
````

````bash
./run.create.sh

# follow the instructions for manual setup step
````
### Upload Results
After running tests, upload results into the blob storage:
````bash
./upload.test-results.sh {directory to test results}
````
### Import Results from Blob into Data Explorer

Follow the instructions at the end of the upload script.

### Kusto Timeseries Graphs

#### Ping
````bash
let min_t = toscalar(ping | summarize min(timestamp));
let max_t = toscalar(ping | summarize max(timestamp));
ping
| make-series rtt_min=sum(metrics_rtt_min_value) default=0, rtt_avg=sum(metrics_rtt_avg_value) default=0, rtt_max=sum(metrics_rtt_max_value) on timestamp in range (min_t, max_t, 1m)
| render timechart
````

#### Latency

how to select the run_id once it is in there?

where run_id=="xxx"
try this one: on timestamp in range (min_t, max_t, 1m) by run_id

````bash
let min_t = toscalar(latency | summarize min(timestamp));
let max_t = toscalar(latency | summarize max(timestamp));
latency
| make-series
     rtt_avg=sum(metrics_latency_latency_stats_95th_percentile_latency_usec) default=0,
     rtt_50=sum(metrics_latency_latency_stats_50th_percentile_latency_usec) default=0,
     rtt_95=sum(metrics_latency_latency_stats_95th_percentile_latency_usec) default=0,
     rtt_99=sum(metrics_latency_latency_stats_95th_percentile_latency_usec) default=0,
     rtt_99_9=sum(metrics_latency_latency_stats_99_9th_percentile_latency_usec) default=0
     on timestamp in range (min_t, max_t, 1m)
| render timechart
````

#### VPN
````bash
let min_t = toscalar(vpn | summarize min(timestamp));
let max_t = toscalar(vpn | summarize max(timestamp));
vpn
| make-series
     avg_rx_msg_rate_per_sec=sum(metrics_averageRxMsgRate) default=0,
     avg_tx_msg_rate_per_sec=sum(metrics_averageTxMsgRate) default=0
     on timestamp in range (min_t, max_t, 1m)
| render timechart
````
---
The End.
