# Azure Data Explorer

> :warning: **experimental**
#### TODOs

- setup Event Hubs for continuous ingestion
  - probably need to get rid of run-id in blob path
- create ARM template to replace az calls
  - also: kusto calls deprecated
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

### Kusto Misc Queries

#### Delete all rows in a table
````js
// scope: the db
.drop extents from {table-name}
````

### Kusto Timeseries Graphs

#### Union of Latency, Latency BrokerNode, Ping
````js
let the_run_id = "2020-10-01-13-26-51";
let min_t = toscalar(latency | where run_id == the_run_id | summarize min(sample_start_timestamp));
let max_t = toscalar(latency | where run_id == the_run_id | summarize max(sample_start_timestamp));
latency
| union ping, latencybrokernode
| make-series
    // lat_rtt_95=avg(metrics_latency_node_latency_latency_stats_95th_percentile_latency_usec),
    // lat_rtt_99=avg(metrics_latency_node_latency_latency_stats_99th_percentile_latency_usec) default=real(null),
    lat_rtt_99_9=max(metrics_latency_node_latency_latency_stats_99_9th_percentile_latency_usec) default=real(null),
    lat_bn_rtt_99_9=max(metrics_broker_node_latency_latency_stats_99_9th_percentile_latency_usec) default=real(null),
    // ping_rtt_min=avg(metrics_ping_rtt_min_value*1000) default = -1,
    // ping_rtt_avg=avg(metrics_ping_rtt_avg_value*1000) default = -1,
    ping_rtt_max=max(metrics_ping_rtt_max_value*1000) default = real(null)
    on todatetime(sample_start_timestamp) in range(min_t, max_t, 1m)
| render timechart
````

#### Ping
````js
// let min_t = toscalar(ping | summarize min(timestamp));
let min_t = toscalar(todatetime("2020-10-01T08:50:00Z"));
let max_t = toscalar(ping | summarize max(sample_start_timestamp));
ping
| make-series
    ping_rtt_min=avg(metrics_ping_rtt_min_value),
    ping_rtt_avg=avg(metrics_ping_rtt_avg_value),
    ping_rtt_max=avg(metrics_ping_rtt_max_value)
    on sample_start_timestamp in range (min_t, max_t, 1m)
    // by run_id
| render timechart
````

#### Latency

````js
let min_t = toscalar(latency | summarize min(sample_start_timestamp));
// let min_t = toscalar(todatetime("2020-09-30T14:16:00Z"));
let max_t = toscalar(latency | summarize max(sample_start_timestamp));
latency
| make-series
     lat_rtt_avg=avg(metrics_latency_node_latency_latency_stats_average_latency_for_subs_usec),
     lat_rtt_50=avg(metrics_latency_node_latency_latency_stats_50th_percentile_latency_usec),
     lat_rtt_95=avg(metrics_latency_node_latency_latency_stats_95th_percentile_latency_usec),
     lat_rtt_99=avg(metrics_latency_node_latency_latency_stats_99th_percentile_latency_usec),
     lat_rtt_99_9=avg(metrics_latency_node_latency_latency_stats_99_9th_percentile_latency_usec)
     on sample_start_timestamp in range (min_t, max_t, 1m)
     // by run_id
| render timechart
````
#### Latency Broker Node
````js
let min_t = toscalar(latencybrokernode | summarize min(sample_start_timestamp));
// let min_t = toscalar(todatetime("2020-09-30T14:16:00Z"));
let max_t = toscalar(latencybrokernode | summarize max(sample_start_timestamp));
latencybrokernode
| make-series
     lat_bn_rtt_avg=max(metrics_broker_node_latency_latency_stats_average_latency_for_subs_usec) default=real(null),
     lat_bn_rtt_50=max(metrics_broker_node_latency_latency_stats_50th_percentile_latency_usec) default=real(null),
     lat_bn_rtt_95=max(metrics_broker_node_latency_latency_stats_95th_percentile_latency_usec) default=real(null),
     lat_bn_rtt_99=max(metrics_broker_node_latency_latency_stats_99th_percentile_latency_usec) default=real(null),
     lat_bn_rtt_99_9=max(metrics_broker_node_latency_latency_stats_99_9th_percentile_latency_usec) default=real(null)
     on sample_start_timestamp in range (min_t, max_t, 1m)
     // by run_id
| render timechart
````
#### VPN
````js
let min_t = toscalar(vpn | summarize min(sample_start_timestamp));
// let min_t = toscalar(todatetime("2020-09-30T14:16:00Z"));
let max_t = toscalar(vpn | summarize max(sample_start_timestamp));
vpn
| make-series
     vpn_avg_rx_msg_rate_per_sec=avg(metrics_averageRxMsgRate),
     vpn_avg_tx_msg_rate_per_sec=avg(metrics_averageTxMsgRate)
     on sample_start_timestamp in range (min_t, max_t, 1m)
     // by run_id
| render timechart
````
---
The End.
