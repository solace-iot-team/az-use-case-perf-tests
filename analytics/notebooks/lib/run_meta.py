from ._util import *
from .constants import *


class RunMeta():

    def __init__(self, metaJson):
        self.run_id = metaJson["meta"]["run_id"]
        self.run_name = metaJson["meta"]["run_name"]
        self.cloud_provider = metaJson["meta"]["cloud_provider"]
        self.infrastructure = metaJson["meta"]["infrastructure"]
        self.ts_run_start = to_date(metaJson["meta"]["run_start_time"], perf_meta_date_ts_pattern)
        self.ts_run_end = to_date(metaJson["meta"]["run_end_time"], perf_meta_date_ts_pattern)

    def __str__(self):
        return f'[PerfMeta: [cloud_provider: {self.cloud_provider}] [run_id: {self.run_id}] [duration (sec): {self.run_duration_sec()}]]'

    def run_duration_sec(self):
        return self.ts_run_end - self.ts_run_start