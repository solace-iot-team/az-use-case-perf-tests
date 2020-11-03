import json

from .base_series import BaseSeries
from .broker_sample import BrokerSample
from .constants import *
from .perf_error import PerfError
from .run import Run


class BrokerSeries(BaseSeries):

    def __init__(self, run: Run):
        BaseSeries.__init__(self, run)
        self.list_samples = list()
        self.read_sample_files()

    def read_sample_files(self):
        list_files = self.files_in_folder_by_pattern(self.run_dir(), perf_run_pattern_vpn_performance_file)
        for file_name in list_files:
            with open(file_name) as sample_file:
                self.list_samples.append(BrokerSample(run=self.run, sample_json=json.load(sample_file)))

    def export_all_metrics(self) -> list:
        return self.export_metrics(c_latency_all_metrics)

    def export_metrics(self, list_metrics: list) -> list:
        result_list = list()
        for series in self.list_samples:
            result_list.extend(series.export_metrics(list_metrics))
        return result_list

    def find_sample(self, sample_num):
        try:
            return next(filter(lambda item: item.sample_num==sample_num, self.list_samples ))
        except StopIteration:
            raise PerfError(f'BrokerSeries - sample_num: {sample_num} not found')