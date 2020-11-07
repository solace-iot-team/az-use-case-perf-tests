# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Jochen Traunecker (jochen.traunecker@solace.com)
# ---------------------------------------------------------------------------------------------

import json

from .base_series import BaseSeries
from .constants import *
from .perf_error import PerfError
from .ping_sample import PingSample


class PingSeries(BaseSeries):

    def __init__(self, run):
        BaseSeries.__init__(self, run)
        self.list_samples = list()
        self.read_sample_files()

    def read_sample_files(self):
        list_files = self.files_in_folder_by_pattern(self.run_dir(), perf_run_pattern_ping_host_file)
        for file_name in list_files:
            with open(file_name) as sample_file:
                self.list_samples.append(PingSample(run=self.run,sample_json=json.load(sample_file)))

    def export_metrics(self, list_metrics: list) -> list:
        result_list = list()
        for series in self.list_samples:
            result_list.extend(series.export_metrics(list_metrics))
        return result_list

    def export_metrics_as_columns(self) -> dict:
        result = {k_ping_rtt_min:list(), k_ping_rtt_max:list(), k_ping_rtt_avg:list(), k_ping_rtt_mdev:list()}
        for sample in self.list_samples:
            result[k_ping_rtt_min].append(sample.ping_rtt_min)
            result[k_ping_rtt_max].append(sample.ping_rtt_max)
            result[k_ping_rtt_avg].append(sample.ping_rtt_avg)
            result[k_ping_rtt_mdev].append(sample.ping_rtt_mdev)
        return result

    def find_sample(self, sample_num):
        try:
            return next(filter(lambda item: item.sample_num==sample_num, self.list_samples ))
        except StopIteration:
            raise PerfError(f'PingSeries - sample_num: {sample_num} not found')