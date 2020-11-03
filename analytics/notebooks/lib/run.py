import array as arr
import json

from .broker_series import BrokerSeries
from .common_base import CommonBase
from .constants import *
from .latency_broker_latency_series import LatencyBrokerLatencySeries
from .latency_node_latency_series import LatencyNodeLatencySeries
from .ping_series import PingSeries
from .run_meta import RunMeta


class Run(CommonBase):

    def __init__(self, run_definition, run_dir: str):
        CommonBase.__init__(self)
        self.run_definition = run_definition
        self.run_dir = run_dir
        #is this run with all contained files parsed
        self.processed = False
        self.success = None
        self.run_meta = None
        self.latency_node_latency_series = None
        self.broker_node_latency_series = None
        self.ping_series = None
        self.broker_series = None
        self.extract_stats()

    def __str__(self):
        return f'[PerfRun: {self.run_meta}  [sucess: {self.success}]] {self.latency_node_latency_series}'

    def extract_stats(self):
        meta_path = self.run_dir + "/" + perf_filename_meta
        self.check_file_exists(meta_path, True, "meta data does not exist")
        with open(meta_path) as meta_file:
            self.run_meta = RunMeta(json.load(meta_file))
        logs_path = self.run_dir + "/" + perf_run_log_dir
        self.check_folder_exists(logs_path, True, "logs folder does not exist")
        success_log = self.files_in_folder_by_pattern(logs_path, perf_run_pattern_success_log_file)
        self.success = len(success_log) == 1
        self.latency_node_latency_series = LatencyNodeLatencySeries(self)
        self.broker_node_latency_series = LatencyBrokerLatencySeries(self)
        self.broker_series = BrokerSeries(self)
        self.ping_series = PingSeries(self)

    def _touch_all_exports(self):
        """
        for internal testing only
        :return:
        """
        self.export_broker_series([k_broker_avg_rx_msg_rate])
        self.export_ping_series([k_ping_rtt_mdev])
        self.export_latency_node_latency_series([k_latency_99_9th])
        self.export_broker_node_latency_series([k_latency_99_9th])
        self.export_latency_node_distinct_latencies()
        self.export_broker_node_distinct_latencies()

    def export_latency_node_latency_series(self, list_metrics) -> list:
        return self.latency_node_latency_series.export_metrics(list_metrics)

    def export_broker_node_latency_series(self, list_metrics) -> list:
        return self.broker_node_latency_series.export_metrics(list_metrics)

    def export_latency_node_distinct_latencies(self) -> arr.array:
        return self.latency_node_latency_series.export_distinct_latencies()

    def export_broker_node_distinct_latencies(self) -> arr.array:
        return self.broker_node_latency_series.export_distinct_latencies()

    def export_latency_node_delta_index_latencies(self, filter_predicate):
        return self.latency_node_latency_series.export_delta_index_latencies(filter_predicate)

    def export_broker_node_delta_index_latencies(self, filter_predicate):
        return self.broker_node_latency_series.export_delta_index_latencies(filter_predicate)

    def export_latency_node_series_length_latencies(self, filter_predicate) -> dict:
        return self.latency_node_latency_series.export_series_length_latencies(filter_predicate)

    def export_broker_node_series_length_latencies(self, filter_predicate) -> dict:
        return self.broker_node_latency_series.export_series_length_latencies(filter_predicate)

    def export_ping_series(self, list_metrics) -> arr.array:
        return self.ping_series.export_metrics(list_metrics)

    def export_broker_series(self, list_metrics) -> arr.array:
        return self.broker_series.export_metrics(list_metrics)