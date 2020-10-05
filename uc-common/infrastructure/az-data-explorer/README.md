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

#### Delete all rows in all tables
````js
// scope: the db
.drop extents from all tables;
latency | take 10;
latencybrokernode | take 10;
meta | take 10;
ping | take 10;
vpn | take 10;
````
#### Delete all rows in a table
````js
// scope: the db
.drop extents from {table-name}
````

### Kusto Timeseries Graphs

#### Latency

````js
let the_run_id = "2020-10-05-14-57-14";
let min_t = toscalar(latency | where run_id == the_run_id | summarize min(sample_start_timestamp));
let max_t = toscalar(latency | where run_id == the_run_id | summarize max(sample_start_timestamp));
let cloud_provider = toscalar(meta | where meta_run_id == the_run_id | project meta_cloud_provider);
let use_case = toscalar(meta | where meta_run_id == the_run_id | project meta_use_case);
latency
| make-series
     lat_rtt_avg=max(['metrics_latency-stats_latency_latency_stats_average_latency_for_subs_usec']) default=real(null),
     lat_rtt_50=max(['metrics_latency-stats_latency_latency_stats_50th_percentile_latency_usec']) default=real(null),
     lat_rtt_95=max(['metrics_latency-stats_latency_latency_stats_95th_percentile_latency_usec']) default=real(null),
     lat_rtt_99=max(['metrics_latency-stats_latency_latency_stats_99th_percentile_latency_usec']) default=real(null),
     lat_rtt_99_9=max(['metrics_latency-stats_latency_latency_stats_99_9th_percentile_latency_usec']) default=real(null)
     on sample_start_timestamp in range (min_t, max_t, 1m)
     // by run_id
| as the_series;
let the_title = strcat("LATENCY:", "cloud:", cloud_provider, " | ", "run-id:", the_run_id, " | ", "use-case:", use_case);
the_series | render timechart with (legend=visible, title=the_title );
````
#### Latency Broker Node
````js
let the_run_id = "2020-10-05-14-57-14";
let min_t = toscalar(latencybrokernode | where run_id == the_run_id | summarize min(sample_start_timestamp));
let max_t = toscalar(latencybrokernode | where run_id == the_run_id | summarize max(sample_start_timestamp));
let cloud_provider = toscalar(meta | where meta_run_id == the_run_id | project meta_cloud_provider);
let use_case = toscalar(meta | where meta_run_id == the_run_id | project meta_use_case);
latencybrokernode
| make-series
     lat_rtt_avg=max(['metrics_latency-brokernode-stats_latency_latency_stats_average_latency_for_subs_usec']) default=real(null),
     lat_rtt_50=max(['metrics_latency-brokernode-stats_latency_latency_stats_50th_percentile_latency_usec']) default=real(null),
     lat_rtt_95=max(['metrics_latency-brokernode-stats_latency_latency_stats_95th_percentile_latency_usec']) default=real(null),
     lat_rtt_99=max(['metrics_latency-brokernode-stats_latency_latency_stats_99th_percentile_latency_usec']) default=real(null),
     lat_rtt_99_9=max(['metrics_latency-brokernode-stats_latency_latency_stats_99_9th_percentile_latency_usec']) default=real(null)
     on sample_start_timestamp in range (min_t, max_t, 1m)
     // by run_id
| as the_series;
let the_title = strcat("LATENCY BROKER NODE:", "cloud:", cloud_provider, " | ", "run-id:", the_run_id, " | ", "use-case:", use_case);
the_series | render timechart with (legend=visible, title=the_title );
````
#### Ping
````js
let the_run_id = "2020-10-05-14-57-14";
let min_t = toscalar(ping | where run_id == the_run_id | summarize min(sample_start_timestamp));
let max_t = toscalar(ping | where run_id == the_run_id | summarize max(sample_start_timestamp));
let cloud_provider = toscalar(meta | where meta_run_id == the_run_id | project meta_cloud_provider);
let use_case = toscalar(meta | where meta_run_id == the_run_id | project meta_use_case);
ping
| make-series
    ping_rtt_min=max(metrics_ping_rtt_min_value),
    ping_rtt_avg=max(metrics_ping_rtt_avg_value),
    ping_rtt_max=max(metrics_ping_rtt_max_value)
    on sample_start_timestamp in range (min_t, max_t, 1m)
    // by run_id
| as the_series;
let the_title = strcat("PING:", "cloud:", cloud_provider, " | ", "run-id:", the_run_id, " | ", "use-case:", use_case);
the_series | render timechart with (legend=visible, title=the_title );
````
#### VPN
````js
let the_run_id = "2020-10-05-14-57-14";
let min_t = toscalar(vpn | where run_id == the_run_id | summarize min(sample_start_timestamp));
let max_t = toscalar(vpn | where run_id == the_run_id | summarize max(sample_start_timestamp));
let cloud_provider = toscalar(meta | where meta_run_id == the_run_id | project meta_cloud_provider);
let use_case = toscalar(meta | where meta_run_id == the_run_id | project meta_use_case);
vpn
| make-series
     vpn_avg_rx_msg_rate_per_sec=avg(metrics_averageRxMsgRate),
     vpn_avg_tx_msg_rate_per_sec=avg(metrics_averageTxMsgRate)
     on sample_start_timestamp in range (min_t, max_t, 1m)
     // by run_id
| as the_series;
let the_title = strcat("VPN:", "cloud:", cloud_provider, " | ", "run-id:", the_run_id, " | ", "use-case:", use_case);
the_series | render timechart with (legend=visible, title=the_title );
````

#### Union of Latency, Latency BrokerNode, Ping
````js
// let the_run_id = "2020-10-05-14-57-14";
let the_run_id = "2020-10-05-16-30-46";
let cloud_provider = toscalar(meta | where meta_run_id == the_run_id | project meta_cloud_provider);
let use_case = toscalar(meta | where meta_run_id == the_run_id | project meta_use_case);
let min_t = toscalar(latency | where run_id == the_run_id | summarize min(sample_start_timestamp));
let max_t = toscalar(latency | where run_id == the_run_id | summarize max(sample_start_timestamp));
latency
| union ping, latencybrokernode
| make-series
    lat_rtt_99_9=max(['metrics_latency-stats_latency_latency_stats_99_9th_percentile_latency_usec']) default=real(null),
    lat_bn_rtt_99_9=max(['metrics_latency-brokernode-stats_latency_latency_stats_99_9th_percentile_latency_usec']) default=real(null),
    ping_rtt_max=max(metrics_ping_rtt_max_value*1000) default = real(null)
    on todatetime(sample_start_timestamp) in range(min_t, max_t, 1m)
| as the_series;
let r_lat_rtt_99_9_x_lat_bn_rtt_99_9 = toscalar(the_series | project series_pearson_correlation(lat_rtt_99_9, lat_bn_rtt_99_9));
let r_lat_rtt_99_9_x_ping_rtt_max = toscalar(the_series | project series_pearson_correlation(lat_rtt_99_9, ping_rtt_max));
let the_title = strcat("cloud:", cloud_provider, " | ", "run-id:", the_run_id, " | ", "use-case:", use_case, " : ", "r(lat,lat_bn)=", r_lat_rtt_99_9_x_lat_bn_rtt_99_9, " | ", "r(lat,ping)=", r_lat_rtt_99_9_x_ping_rtt_max);
the_series | render timechart with (legend=visible, title=the_title );
````






---
The End.
