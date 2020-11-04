
import array as arr

from ._constants import *
from ._util import *
from .base_sample import BaseSample
from .constants import *

class LatencySample(BaseSample):

    def __init__(self, run, sample_json):
        BaseSample.__init__(self, run)
        self.read_metrics(sample_json)
        self.arr_latency = arr.array("i")
        if (self.run.run_definition._process_distinct_latency_samples):
            self.read_distinct_latencies(sample_json)

    def __str__(self):
        return f'[PerfStatLatency [run_id: {self.run_id}] [sample_num: {self.sample_num}] [len(arr_latency): {len(self.arr_latency)}]]'

    def read_metrics(self, sample_json):
        self.run_id = sample_json["run_id"]
        self.ts_start = to_date(sample_json["sample_start_timestamp"], perf_latency_date_ts_pattern)
        self.sample_num = int(sample_json["sample_num"])
        self.metrics_type = sample_json["metrics_type"]
        self.host = sample_json["meta"]["host"]
        self.cpu_usage_pct = float(sample_json["metrics"]["cpu_usage_pct"])
        self.individual_latency_bucket_size_usec = float(
            sample_json["metrics"]["latency"]["latency_info"]["individual_latency_bucket_size_usec"])
        self.latency_messages_received = int(
            sample_json["metrics"]["latency"]["latency_info"]["latency_messages_received"])
        self.latency_msg_rate = float(sample_json["metrics"]["latency"]["latency_info"]["latency_msg_rate"])
        self.latency_warmup_sec = float(sample_json["metrics"]["latency"]["latency_info"]["latency_warmup_sec"])

        self.latency_50th_percentile = float(
            sample_json["metrics"]["latency"]["latency_stats"]["50th_percentile_latency_usec"])
        self.latency_95th_percentile = float(
            sample_json["metrics"]["latency"]["latency_stats"]["95th_percentile_latency_usec"])
        self.latency_99_9th_percentile = float(
            sample_json["metrics"]["latency"]["latency_stats"]["99.9th_percentile_latency_usec"])
        self.latency_99th_percentile = float(
            sample_json["metrics"]["latency"]["latency_stats"]["99th_percentile_latency_usec"])

        self.latency_average = float(sample_json["metrics"]["latency"]["latency_stats"]["average_latency_for_subs_usec"])
        self.latency_maximum = float(sample_json["metrics"]["latency"]["latency_stats"]["maximum_latency_for_subs_usec"])
        self.latency_minimum = float(sample_json["metrics"]["latency"]["latency_stats"]["minimum_latency_for_subs_usec"])
        self.latency_standard_deviation = float(
            sample_json["metrics"]["latency"]["latency_stats"]["standard_deviation_usec"])

    def read_distinct_latencies(self, sample_json):
        for lat in sample_json["metrics"]["latency_per_message_in_usec"]:
            self.arr_latency.append(int(lat))

    def export_all_metrics(self) -> list:
        return self.export_metrics(c_latency_all_metrics)

    def export_metrics(self, list_metrics: list) -> list:
        rows = list()
        for metric in list_metrics:
            row = dict()
            row[k_provider] = self.run.run_meta.cloud_provider
            row[k_infrastructure] = self.run.run_meta.infrastructure
            row[k_run_id] = self.run_id
            row[k_ts] = self.ts_start
            row[k_sample_num] = self.sample_num
            row['metric'] = metric
            row['value'] = self.__getattribute__(d_metric_property[metric])
            rows.append(row)
        return rows

    def export_distinct_latencies(self) -> arr:
        return self.arr_latency

    def export_latency_node_series_latencies(self):
        arr_sample_num = arr.array("i")
        arr_sample_index = arr.array("i")
        arr_sample_latency = arr.array("i")
        i = 0
        while i<len(self.arr_latency):
            arr_sample_num.append(self.sample_num)
            arr_sample_index.append(i)
            arr_sample_latency.append(self.arr_latency[i])
            i += 1
        result_dict = {k_sample_num:arr_sample_num,k_sample_index:arr_sample_index, k_latency:arr_sample_latency}
        return result_dict

    def export_delta_index_latencies(self, filter_predicate) -> arr:
        """
        Index distances between two latencies that fulfill filter_predicate
        :param filter_predicate:
        :return:
        """
        last_index = -1
        result_arr = arr.array("i")
        i = 0
        while i<len(self.arr_latency):
            if (filter_predicate(self.arr_latency[i])):
                if last_index == -1:
                    last_index = i
                else:
                    result_arr.append(i-last_index)
                    last_index = i
            i += 1
        return result_arr

    def export_series_length_latencies(self, filter_predicate) -> dict:
        """
        Index distances between two latencies that fulfill filter_predicate
        :param filter_predicate:
        :return:
        """
        active_series=False
        predicate_fit = False
        series_distance= 0
        gap_distance = 0
        last_index = -1
        series_arr = arr.array("i")
        gap_arr = arr.array("i")
        i = 0
        while i<len(self.arr_latency):
            predicate_fit = filter_predicate(self.arr_latency[i])
            if active_series:
                if predicate_fit:
                    series_distance += 1
                else:
                    if series_distance>0:
                        series_arr.append(series_distance)
                    #reset series
                    active_series=False
                    series_distance=0
            else:
                if predicate_fit:
                    #edge case - first element is a fit
                    if i>0:
                        gap_arr.append(gap_distance)
                    #reset gap series
                    active_series = True
                    gap_distance = 0
                else:
                    active_series = False
                    gap_distance += 1
            i += 1
        return {k_latency_series_length:series_arr, k_latency_gap_length:gap_arr}