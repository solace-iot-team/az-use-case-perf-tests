# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Jochen Traunecker (jochen.traunecker@solace.com)
# ---------------------------------------------------------------------------------------------

from .constants import *

# p_constants for internal use only, represent properties in distinct classes
p_latency_metric_50th = "latency_50th_percentile"
p_latency_95th_percentile = "latency_95th_percentile"
p_latency_99_9th_percentile = "latency_99_9th_percentile"
p_latency_99th_percentile = "latency_99th_percentile"
p_latency_average = "latency_average"
p_latency_maximum = "latency_maximum"
p_latency_minimum = "latency_minimum"
p_latency_standard_deviation = "latency_standard_deviation"
p_ping_rtt_avg = "ping_rtt_avg"
p_ping_rtt_max = "ping_rtt_max"
p_ping_rtt_min = "ping_rtt_min"
p_ping_rtt_mdev = "ping_rtt_mdev"
p_broker_tx_msg_count = "broker_tx_msg_count"
p_broker_rx_msg_count = "broker_rx_msg_count"
p_broker_avg_tx_msg_rate = "broker_avg_tx_msg_rate"
p_broker_avg_rx_msg_rate = "broker_avg_rx_msg_rate"
p_broker_discard_tx_msg_count = "broker_discard_tx_msg_count"
p_broker_discard_rx_msg_count = "broker_discard_rx_msg_count"

# mapping between k_constants and p_properties
# for internal use only
d_metric_property = {
    k_latency_50th: p_latency_metric_50th,
    k_latency_95th: p_latency_95th_percentile,
    k_latency_99th: p_latency_99th_percentile,
    k_latency_99_9th: p_latency_99_9th_percentile,
    k_latency_average: p_latency_average,
    k_latency_maximum: p_latency_maximum,
    k_latency_minimum: p_latency_minimum,
    k_latency_std_deviation: p_latency_standard_deviation,
    k_ping_rtt_avg: p_ping_rtt_avg,
    k_ping_rtt_max: p_ping_rtt_max,
    k_ping_rtt_min: p_ping_rtt_min,
    k_ping_rtt_mdev: p_ping_rtt_mdev,
    k_broker_tx_msg_count: p_broker_tx_msg_count,
    k_broker_rx_msg_count: p_broker_rx_msg_count,
    k_broker_avg_tx_msg_rate: p_broker_avg_tx_msg_rate,
    k_broker_avg_rx_msg_rate: p_broker_avg_rx_msg_rate,
    k_broker_discard_tx_msg_count: p_broker_discard_tx_msg_count,
    k_broker_discard_rx_msg_count: p_broker_discard_rx_msg_count
}






