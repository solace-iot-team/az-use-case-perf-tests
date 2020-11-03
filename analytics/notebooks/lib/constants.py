# constants related to sample json files
perf_pattern_run_dir = "run.*"
perf_run_log_dir = "logs"
perf_run_pattern_success_log_file = "*.SUCCESS.log"
perf_run_pattern_latency_broker_file = "latency_brokernode_stats*.json"
perf_run_pattern_latency_dedicated_host_file = "latency_stats.*.json"
perf_run_pattern_ping_host_file = "ping_stats.*.json"
perf_run_pattern_vpn_performance_file = "vpn_stats.*.json"

perf_filename_meta = "meta.json"
perf_meta_date_ts_pattern = '%Y-%m-%d %H:%M:%S+%f'
perf_latency_date_ts_pattern = '%Y-%m-%d %H:%M:%S+%f'

# k_constants  are rendered in exported data structures (keys in dicts, ...)
k_infrastructure = "infrastructure"
k_provider = "provider"
k_run_id = "run_id"
k_ts = "ts"
k_sample_num = "sample_num"
k_latency_50th = "50th"
k_latency_95th = "95th"
k_latency_99th = "99th"
k_latency_99_9th = "99_9th"
k_latency_average = "average"
k_latency_maximum = "maximum"
k_latency_minimum = "minimum"
k_latency_std_deviation = "std_deviation"
k_ping_rtt_max = "rtt_max"
k_ping_rtt_min = "rtt_min"
k_ping_rtt_avg = "rtt_avg"
k_ping_rtt_mdev = "rtt_medv"
k_broker_tx_msg_count = "tx_msg_count"
k_broker_rx_msg_count = "rx_msg_count"
k_broker_avg_tx_msg_rate = "broker_avg_tx_msg_rate"
k_broker_avg_rx_msg_rate = "broker_avg_rx_msg_rate"
k_broker_discard_tx_msg_count = "broker_discard_tx_msg_count"
k_broker_discard_rx_msg_count = "broker_discard_rx_msg_count"

k_latency_series_length = "series_length"
k_latency_gap_length = "gap_length"

# collection of k_constants
c_latency_all_metrics= [k_latency_50th, k_latency_95th, k_latency_99th, k_latency_99_9th, k_latency_average, k_latency_maximum, k_latency_minimum, k_latency_std_deviation]
c_ping_all_metrics = [k_ping_rtt_avg, k_ping_rtt_max, k_ping_rtt_min, k_ping_rtt_mdev]
c_broker_all_metrics = [k_broker_tx_msg_count, k_broker_rx_msg_count, k_broker_avg_tx_msg_rate, k_broker_avg_rx_msg_rate, k_broker_discard_tx_msg_count, k_broker_discard_rx_msg_count]

c_sample_metric_type_latency_node = "latency_stats"
c_sample_metric_type_latency_broker = "latency_brokernode_stats"
c_sample_metric_type_ping = "ping"
c_sample_metric_vpn = "vpn_stats"