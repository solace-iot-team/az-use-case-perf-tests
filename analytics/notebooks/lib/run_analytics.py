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

class RunAnalytics():

    def __init__(self, run):
        self.run = run


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
            self.add_to_dict(result,k_latency_minimum, tmp_df['sample'].min())
            self.add_to_dict(result,k_latency_maximum, tmp_df['sample'].max())
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
            # self.add_to_dict(result,k_latency_minimum, tmp_df['sample'].min())
            # self.add_to_dict(result,k_latency_maximum, tmp_df['sample'].max())
            self.add_to_dict(result,k_latency_average, tmp_df['sample'].mean())
            for map_key,map_percentile in d_latency_percentile.items():
                self.add_to_dict(result,map_key, tmp_quantiles[map_percentile])
        return result



    def add_to_dict(self, target:dict, the_key, the_value):
        if the_key in target:
            target[the_key].append(the_value)
        else:
            target[the_key]=list()
            target[the_key].append(the_value)