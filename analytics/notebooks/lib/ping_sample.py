# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Jochen Traunecker (jochen.traunecker@solace.com)
# ---------------------------------------------------------------------------------------------

from ._util import *
from .base_sample import BaseSample
from ._constants import *


class PingSample(BaseSample):

    def __init__(self, run, sample_json):
        BaseSample.__init__(self, run)
        self.read_metrics(sample_json)

    def read_metrics(self, sample_json):
        self.run_id = sample_json["run_id"]
        self.ts_start = to_date(sample_json["sample_start_timestamp"], perf_latency_date_ts_pattern)
        self.sample_num = int(sample_json["sample_num"])
        self.metrics_type = sample_json["metrics_type"]
        self.ping_rtt_avg = float(sample_json["metrics"]["rtt_avg"]["value"])
        self.ping_rtt_max = float(sample_json["metrics"]["rtt_max"]["value"])
        self.ping_rtt_min = float(sample_json["metrics"]["rtt_min"]["value"])
        self.ping_rtt_mdev = float(sample_json["metrics"]["rtt_mdev"]["value"])

    def export_all_metrics(self) -> list:
        return self.export_metrics(c_ping_all_metrics)

    def export_metrics(self, list_metrics: list) -> list:
        rows = list()
        for metric in list_metrics:
            row = dict()
            row[k_run_id] = self.run_id
            row[k_ts] = self.ts_start
            row[k_sample_num] = self.sample_num
            row['metric'] = metric
            row['value'] = self.__getattribute__(d_metric_property[metric])
            rows.append(row)
        return rows

