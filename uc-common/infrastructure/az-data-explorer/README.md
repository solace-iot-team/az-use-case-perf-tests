# Azure Data Explorer

> :warning: **experimental**
#### TODOs

- setup Event Hubs for continuous ingestion
  - probably need to get rid of run-id in blob path
- create ARM template to replace az calls
  - also: kusto calls deprecated
- ping results:
  - omit data point entirely, don't use "-1"
- create a single graph with
  - latency + ping together
- annotate the graphs with title, axis, etc.


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
| make-series
    rtt_min=avg(metrics_rtt_min_value),
    rtt_avg=avg(metrics_rtt_avg_value),
    rtt_max=avg(metrics_rtt_max_value)
    on timestamp in range (min_t, max_t, 2m) by run_id
| render timechart
````

#### Latency


````bash
let min_t = toscalar(latency | summarize min(timestamp));
let max_t = toscalar(latency | summarize max(timestamp));
latency
| make-series
     rtt_avg=avg(metrics_latency_latency_stats_average_latency_for_subs_usec) default=0,
     rtt_50=avg(metrics_latency_latency_stats_50th_percentile_latency_usec) default=0,
     rtt_95=avg(metrics_latency_latency_stats_95th_percentile_latency_usec) default=0,
     rtt_99=avg(metrics_latency_latency_stats_99th_percentile_latency_usec) default=0,
     rtt_99_9=avg(metrics_latency_latency_stats_99_9th_percentile_latency_usec) default=0
     on timestamp in range (min_t, max_t, 2m) by run_id
| render timechart
````

#### VPN
````bash
let min_t = toscalar(vpn | summarize min(timestamp));
let max_t = toscalar(vpn | summarize max(timestamp));
vpn
| make-series
     avg_rx_msg_rate_per_sec=avg(metrics_averageRxMsgRate) default=0,
     avg_tx_msg_rate_per_sec=avg(metrics_averageTxMsgRate) default=0
     on timestamp in range (min_t, max_t, 2m) by run_id
| render timechart
````
---
The End.
