import json
from array import array as arr

from .base_series import BaseSeries
from .constants import *
from .perf_error import PerfError
from .run import Run
from .latency_sample import LatencySample


class LatencyNodeLatencySeries(BaseSeries):

    def __init__(self, run: Run):
        BaseSeries.__init__(self, run)
        self.list_samples = list()
        self.read_sample_files()

    def __str__(self):
        return f'[LatencyNodeLatencySeries [len(list_stats): {len(self.list_samples)}]]'

    def read_sample_files(self):
        list_files = self.files_in_folder_by_pattern(self.run_dir(), perf_run_pattern_latency_dedicated_host_file)
        for latency_file_name in list_files:
            with open(latency_file_name) as latency_file:
                self.list_samples.append(LatencySample(run=self.run, sample_json=json.load(latency_file)))

    def export_metrics(self, list_metrics: list) -> list:
        result_list = list()
        for series in self.list_samples:
            result_list.extend(series.export_metrics(list_metrics))
        return result_list

    def export_distinct_latencies(self) -> arr:
        result_array = arr.array("i")
        for series in sorted(self.list_samples, key=lambda sample: sample.sample_num):
            result_array.extend(series.export_distinct_latencies())
        return result_array

    def export_delta_index_latencies(self, filter_predicate) -> arr:
        result_array = arr.array("i")
        for series in sorted(self.list_samples, key=lambda sample: sample.sample_num):
            result_array.extend(series.export_delta_index_latencies(filter_predicate))
        return result_array

    def export_series_length_latencies(self, filter_predicate) -> dict:
        result_dict = {"series_length":arr.array("i"), "gap_length":arr.array("i")}

        for series in sorted(self.list_samples, key=lambda sample: sample.sample_num):
            series_result_dict = series.export_series_length_latencies(filter_predicate)
            result_dict[k_latency_series_length].extend(series_result_dict["series_length"])
            result_dict[k_latency_gap_length].extend(series_result_dict["gap_length"])

        return result_dict

    def find_sample(self, sample_num):
        try:
            return next(filter(lambda item: item.sample_num==sample_num, self.list_samples ))
        except StopIteration:
            raise PerfError(f'LatencyNodeLatencySeries - sample_num: {sample_num} not found')