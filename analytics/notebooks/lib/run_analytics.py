# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Jochen Traunecker (jochen.traunecker@solace.com)
# ---------------------------------------------------------------------------------------------

import array as arr
import json

from .broker_series import BrokerSeries
from .common_base import CommonBase
from .constants import *
from ._constants import *
from .latency_broker_latency_series import LatencyBrokerLatencySeries
from .latency_node_latency_series import LatencyNodeLatencySeries
from .ping_series import PingSeries
from .run_meta import RunMeta
from .run import Run
import numpy as np
import pandas as pd


CHECK_PASSING_MD="**<span style='color:green'>passing</span>**"
CHECK_FAILING_MD="**<span style='color:red'>failing</span>**"

d_latency_percentile = {
    # k_latency_00_05th : 0.005,
    # k_latency_01_th : 0.01,
    # k_latency_00_5th : 0.05,
    # k_latency_10th : 0.10,
    # k_latency_25th : 0.25,
    k_latency_50th : 0.5,
    # k_latency_75th : 0.75,
    k_latency_90th : 0.90,
    k_latency_95th : 0.95,
    k_latency_99th : 0.99,
    k_latency_99_5th : 0.995,
    k_latency_99_9th : 0.999,
    # k_latency_99_95th : 0.9995,
    # k_latency_99_99th : 0.9999,
    # k_latency_99_995th : 0.99995,
    # k_latency_99_999th : 0.99999,
}

class RunAnalytics():

    def __init__(self, run):
        self.run = run

    def export_broker_node_distinct_latencies_as_dataframe(self, col_name:str ="run"):
       return pd.DataFrame(data={col_name: self.run.export_broker_node_distinct_latencies()})

    def export_latency_node_distinct_latencies_as_dataframe(self, col_name:str ="run"):
        return pd.DataFrame(data={col_name: self.run.export_latency_node_distinct_latencies()})

    def export_latency_node_series_latencies_metrics_as_dataframe(self):
        return pd.DataFrame(data=self.export_latency_node_series_latencies_metrics())

    def export_broker_node_series_latencies_metrics_as_dataframe(self):
        return pd.DataFrame(data=self.export_broker_node_series_latencies_metrics())

    def export_broker_node_series_latencies_metrics(self):
        result = dict()
        #quantiles
        percentiles = list(d_latency_percentile.values())
        lat_dict =self.run.export_broker_node_distinct_latencies_per_sample()
        for key, value in lat_dict.items():
            tmp_df = pd.DataFrame(data={"sample":value})
            tmp_quantiles = tmp_df['sample'].quantile(q=percentiles)
            #self.add_to_dict(result,k_latency_minimum, tmp_df['sample'].min())
            #self.add_to_dict(result,k_latency_maximum, tmp_df['sample'].max())
            self.add_to_dict(result,k_latency_average, tmp_df['sample'].mean())
            for map_key,map_percentile in d_latency_percentile.items():
                self.add_to_dict(result,map_key, tmp_quantiles[map_percentile])

        return result

    def export_latency_node_series_latencies_metrics(self):
        result = dict()
        #quantiles
        percentiles = list(d_latency_percentile.values())
        lat_dict =self.run.export_latency_node_distinct_latencies_per_sample()
        for key, value in lat_dict.items():
            tmp_df = pd.DataFrame(data={"sample":value})
            tmp_quantiles = tmp_df['sample'].quantile(q=percentiles)
            #self.add_to_dict(result,k_latency_minimum, tmp_df['sample'].min())
            #self.add_to_dict(result,k_latency_maximum, tmp_df['sample'].max())
            self.add_to_dict(result,k_latency_average, tmp_df['sample'].mean())
            for map_key,map_percentile in d_latency_percentile.items():
                self.add_to_dict(result,map_key, tmp_quantiles[map_percentile])
        return result


    def export_combined_all_distinct_latencies_metrics(self) -> dict:
        """
        Calculates metrics (min, max, mean, percentiles) for broker and latency nodes

        :return: dict ['metrics"]['latency-node']['broker-node']
        """
        percentiles = list(d_latency_percentile.values())
        ln_latencies = self.run.export_latency_node_distinct_latencies()
        bn_latencies = self.run.export_broker_node_distinct_latencies()
        tmp_df = pd.DataFrame(data={"latencies":ln_latencies})
        tmp_quantiles = tmp_df['latencies'].quantile(q=percentiles)

        list_metrics = [k_latency_minimum,k_latency_average]
        list_metrics += list(d_latency_percentile.keys())
        list_metrics.append(k_latency_maximum)

        list_latency_node = list()
        list_latency_node.append(tmp_df['latencies'].min())
        list_latency_node.append(tmp_df['latencies'].mean())
        for map_key,map_percentile in d_latency_percentile.items():
            list_latency_node.append(tmp_quantiles[map_percentile])
        list_latency_node.append(tmp_df['latencies'].max())

        tmp_df = pd.DataFrame(data={"latencies":bn_latencies})
        tmp_quantiles = tmp_df['latencies'].quantile(q=percentiles)

        list_broker_node = list()
        list_broker_node.append(tmp_df['latencies'].min())
        list_broker_node.append(tmp_df['latencies'].mean())
        for map_key,map_percentile in d_latency_percentile.items():
            list_broker_node.append(tmp_quantiles[map_percentile])
        list_broker_node.append(tmp_df['latencies'].max())

        return {"metrics":list_metrics, "latency-node":list_latency_node, "broker-node":list_broker_node}



    def export_combined_all_distinct_latencies_metrics_as_keyvalue_dataframe(self):
        return pd.DataFrame(self.export_latency_node_all_distinct_latencies_as_keyvalue_metrics() + self.export_broker_node_all_distinct_latencies_as_keyvalue_metrics())

    def export_latency_node_all_distinct_latencies_metrics_as_keyvalue_dataframe(self):
        return pd.DataFrame(self.export_latency_node_all_distinct_latencies_as_keyvalue_metrics())

    def export_latency_node_all_distinct_latencies_as_keyvalue_metrics(self):
        rows = list()
        percentiles = list(d_latency_percentile.values())
        latencies = self.run.export_latency_node_distinct_latencies()
        tmp_df = pd.DataFrame(data={"latencies":latencies})
        tmp_quantiles = tmp_df['latencies'].quantile(q=percentiles)
        rows.append({ 'node': 'latency-node','metric' : k_latency_minimum, 'value': tmp_df['latencies'].min() })
        rows.append({ 'node': 'latency-node','metric' : k_latency_average, 'value': tmp_df['latencies'].mean() })
        for map_key,map_percentile in d_latency_percentile.items():
            rows.append({ 'node': 'latency-node','metric' : map_key, 'value': tmp_quantiles[map_percentile] })
        rows.append({ 'node': 'latency-node','metric' : k_latency_maximum, 'value': tmp_df['latencies'].max() })
        return rows

    def export_broker_node_all_distinct_latencies_metrics_as_keyvalue_dataframe(self):
            return pd.DataFrame(self.export_broker_node_all_distinct_latencies_as_keyvalue_metrics())

    def export_broker_node_all_distinct_latencies_as_keyvalue_metrics(self):
        rows = list()
        percentiles = list(d_latency_percentile.values())
        latencies = self.run.export_latency_node_distinct_latencies()
        tmp_df = pd.DataFrame(data={"latencies":latencies})
        tmp_quantiles = tmp_df['latencies'].quantile(q=percentiles)
        rows.append({ 'node': 'broker-node','metric' : k_latency_minimum, 'value': tmp_df['latencies'].min() })
        rows.append({ 'node': 'broker-node','metric' : k_latency_average, 'value': tmp_df['latencies'].mean() })
        for map_key,map_percentile in d_latency_percentile.items():
            rows.append({ 'node': 'broker-node','metric' : map_key, 'value': tmp_quantiles[map_percentile] })
        rows.append({ 'node': 'broker-node','metric' : k_latency_maximum, 'value': tmp_df['latencies'].max() })
        return rows

    def export_latency_node_all_distinct_latencies_metrics_as_dataframe(self):
        return pd.DataFrame(data=self.export_latency_node_all_distinct_latencies_metrics())

    def export_latency_node_all_distinct_latencies_metrics(self):
        result = dict()
        percentiles = list(d_latency_percentile.values())
        latencies = self.run.export_latency_node_distinct_latencies()
        tmp_df = pd.DataFrame(data={"latencies":latencies})
        tmp_quantiles = tmp_df['latencies'].quantile(q=percentiles)
        self.add_to_dict(result,k_latency_average, tmp_df['latencies'].mean())
        self.add_to_dict(result,k_latency_maximum, tmp_df['latencies'].max())
        self.add_to_dict(result,k_latency_minimum, tmp_df['latencies'].min())
        for map_key,map_percentile in d_latency_percentile.items():
            self.add_to_dict(result,map_key, tmp_quantiles[map_percentile])
        return result

    def export_broker_node_all_distinct_latencies_metrics_as_dataframe(self):
        return pd.DataFrame(data=self.export_broker_node_all_distinct_latencies_metrics())

    def export_broker_node_all_distinct_latencies_metrics(self):
        result = dict()
        percentiles = list(d_latency_percentile.values())
        latencies = self.run.export_broker_node_distinct_latencies()
        tmp_df = pd.DataFrame(data={"latencies":latencies})
        tmp_quantiles = tmp_df['latencies'].quantile(q=percentiles)
        self.add_to_dict(result,k_latency_average, tmp_df['latencies'].mean())
        self.add_to_dict(result,k_latency_maximum, tmp_df['latencies'].max())
        self.add_to_dict(result,k_latency_minimum, tmp_df['latencies'].min())
        for map_key,map_percentile in d_latency_percentile.items():
            self.add_to_dict(result,map_key, tmp_quantiles[map_percentile])
        return result

    def export_ping_series_as_dataframe(self):
        return pd.DataFrame(data=self.run.export_ping_series(c_ping_all_metrics))

    def export_ping_series_as_columns_dataframe(self):
        return pd.DataFrame(data=self.run.export_ping_metrics_as_columns())

    def add_to_dict(self, target:dict, the_key, the_value):
        if the_key in target:
            target[the_key].append(the_value)
        else:
            target[the_key]=list()
            target[the_key].append(the_value)

    def export_consumer_messages_received_as_dataframe(self):
        names, values = self.run.run_meta.getConsumerNamesValues4Plotting()
        return pd.DataFrame(
            data=dict(
                consumer_names=names,
                messages_received=values
            )
        )

    def getChecksAsMarkdown(self):

        num_discarded_messages = 0
        if self.run.broker_series and self.run.broker_series.aggregates:
            num_discarded_messages += self.run.broker_series.aggregates["vpn"]["discard_rx_msg_count"] + self.run.broker_series.aggregates["vpn"]["discard_tx_msg_count"]
        num_discarded_messages += self.run.run_meta.getPublisherAggregates()["rxDiscardedMsgCount"]
        num_discarded_messages += self.run.run_meta.getConsumerAggregates()["txDiscardedMsgCount"]
        zeroMessageLossCheckResult = CHECK_FAILING_MD if num_discarded_messages > 0 else CHECK_PASSING_MD

        msg_tally = 0
        if self.run.broker_series and self.run.broker_series.aggregates:
            msg_tally += self.run.broker_series.aggregates["vpn"]["rx_msg_count"] \
                            + self.run.broker_series.aggregates["vpn"]["discard_rx_msg_count"] \
                            - self.run.broker_series.aggregates["vpn"]["discard_tx_msg_count"] \
                            - self.run.broker_series.aggregates["vpn"]["tx_msg_count"]
        msgTallyCheckResult = CHECK_FAILING_MD if msg_tally != 0 else CHECK_PASSING_MD

        md = f"""
Checks: zero-message-loss:{zeroMessageLossCheckResult} | message-tally:{msgTallyCheckResult}
        """
        return md

###
# The End.            