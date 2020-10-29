import logging
import datetime
import json
import glob
import os.path
from os import path
import array as arr
from jsonpath_ng import jsonpath, parse

# k_constants  are rendered in exported data structures (keys in dicts, ...)
k_infrastructure = "infrastructure"
k_provider = "provider"
k_run_id = "run_id"
k_ts = "ts"
k_sample_num = "sample_num"
k_latency_50th = "50th"
k_latency_95th = "95th"
k_latency_99th = "99th"
k_latency_99_9th = "99_9th"
k_latency_average = "average"
k_latency_maximum = "maximum"
k_latency_minimum = "minimum"
k_latency_std_deviation = "std_deviation"
k_ping_rtt_max = "rtt_max"
k_ping_rtt_min = "rtt_min"
k_ping_rtt_avg = "rtt_avg"
k_ping_rtt_mdev = "rtt_medv"
k_broker_tx_msg_count = "tx_msg_count"
k_broker_rx_msg_count = "rx_msg_count"
k_broker_avg_tx_msg_rate = "broker_avg_tx_msg_rate"
k_broker_avg_rx_msg_rate = "broker_avg_rx_msg_rate"
k_broker_discard_tx_msg_count = "broker_discard_tx_msg_count"
k_broker_discard_rx_msg_count = "broker_discard_rx_msg_count"

# collection of k_constants
c_latency_all_metrics= [k_latency_50th, k_latency_95th, k_latency_99th, k_latency_99_9th, k_latency_average, k_latency_maximum, k_latency_minimum, k_latency_std_deviation]
c_ping_all_metrics = [k_ping_rtt_avg, k_ping_rtt_max, k_ping_rtt_min, k_ping_rtt_mdev]
c_broker_all_metrics = [k_broker_tx_msg_count, k_broker_rx_msg_count, k_broker_avg_tx_msg_rate, k_broker_avg_rx_msg_rate, k_broker_discard_tx_msg_count, k_broker_discard_rx_msg_count]

c_sample_metric_type_latency_node = "latency_stats"
c_sample_metric_type_latency_broker = "latency_brokernode_stats"
c_sample_metric_type_ping = "ping"
c_sample_metric_vpn = "vpn_stats"

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

# constants related to sample json files
perf_pattern_run_dir = "run.*"
perf_run_log_dir = "logs"
perf_run_pattern_success_log_file = "*.SUCCESS.log"
perf_run_pattern_latency_broker_file = "latency_brokernode_stats*.json"
perf_run_pattern_latency_dedicated_host_file = "latency_stats.*.json"
perf_run_pattern_ping_host_file = "ping_stats.*.json"
perf_run_pattern_vpn_performance_file = "vpn_stats.*.json"

perf_filename_meta = "meta.json"
perf_meta_date_ts_pattern = '%Y-%m-%d %H:%M:%S+%f'
perf_latency_date_ts_pattern = '%Y-%m-%d %H:%M:%S+%f'



def to_date(text: str, pattern: str) -> datetime:
    return datetime.datetime.strptime(text, pattern)

class PerfError(Exception):

    def __init__(self, message:str):
        self.message = message

    def __str__(self):
        return f'[PerfError [message:{self.message}]]'

class RunResultLocation:

    def __init__(self, root_folder: str):
        self.root_folder = root_folder



class CommonBase:

    def files_in_folder_by_pattern(self, folder, pattern):
        return glob.glob(folder + "/" + pattern)

    def check_folder_exists(self, path_to_folder: str, raise_exception: bool = False,
                          msg: str = "directory does not exist") -> bool:
        exists_check = (path.exists(path_to_folder) and os.path.isdir(path_to_folder))
        if (not exists_check and raise_exception):
            raise SystemExit(f'[FATAL] [EXITING] {msg}:{path_to_folder}')
        return exists_check

    def check_file_exists(self, path_to_file: str, raise_exception: bool = False,
                        msg: str = "file does not exist") -> bool:
        exists_check = (path.exists(path_to_file) and os.path.isfile(path_to_file))
        if (not exists_check and raise_exception):
            raise SystemExit(f'[FATAL] [EXITING] {msg}:{path_to_file}')
        return exists_check


class RunDefinition(CommonBase):

    def __init__(self, location: RunResultLocation):
        """
        RunDefinition triggers processing all runs within RunResultLocation and provides functions to extract data

        ++
        :param location:
        """
        CommonBase.__init__(self)
        self._location = location
        self._list_runs = list()
        self._process_distinct_latency_samples=True
        self._processed_samples = False

    def process_run_samples(self, process_distinct_latency_samples:bool=True):
        rootExists = self._check_root_folder_in_run_location()
        self._process_distinct_latency_samples = process_distinct_latency_samples
        if not rootExists:
            raise SystemExit(f'[FATAL] [EXITING] Root folder does not exist:{self._location.root_folder}')
        for run_dir in self._read_list_runs():
            self._list_runs.append(Run(self, run_dir))
        self._processed_samples = True

    def _file_path_in_run_location(self, filename: str) -> str:
        return self._location.root_folder + "/" + filename

    def _check_file_in_run_location(self, filename: str) -> bool:
        return path.exists(self._file_path_in_run_location(filename))

    def _check_root_folder_in_run_location(self) -> bool:
        return path.exists(self._location.root_folder)

    def _files_in_run_location(self, pattern):
        return glob.glob(self._file_path_in_run_location(perf_pattern_run_dir))

    def _dirs_in_run_location(self, pattern):
        candidates = glob.glob(self._file_path_in_run_location(perf_pattern_run_dir))
        return list(filter(lambda file: os.path.isdir(file), candidates))

    def _check_processed_sampled(self):
        if not self._processed_samples:
            raise SystemExit(f'[ERROR] [EXITING] RunDefinition not initialized. Execute >process_run_samples() once to read all sample data.<')

    def _read_list_runs(self) -> list:
        return self._dirs_in_run_location(perf_pattern_run_dir)


    def all_runs(self) -> list:
        """
        All runs
        :return: list of all runs
        """
        self._check_processed_sampled()
        return self._list_runs

    def find_run(self,run_id):
        """
        Searches for run with run_id

        :param run_id:
        :return: Run
        :raise: PerfError: if run_id was not found
        """
        self._check_processed_sampled()
        try:
            return next(filter(lambda item: item.run_meta.run_id==run_id, self._list_runs))
        except StopIteration:
            raise PerfError(f'run_id: {run_id} not found')


    def find_sample(self,run_id, metrics_type, sample_num):
        """
        Searches for specific sample

        :param run_id:
        :param metrics_type: {c_sample_metric_type_latency_node | c_sample_metric_type_latency_broker | c_sample_metric_type_ping | c_sample_metric_vpn}
        :param sample_num:
        :return: sample
        :raises PerfError
        """
        self._check_processed_sampled()
        run = self.find_run(run_id)
        if (metrics_type==c_sample_metric_type_latency_node):
            return run.latency_node_latency_series.find_sample(sample_num)
        if (metrics_type==c_sample_metric_type_latency_broker):
            return run.broker_node_latency_series.find_sample(sample_num)
        if (metrics_type==c_sample_metric_type_ping):
            return run.ping_series.find_sample(sample_num)
        if (metrics_type==c_sample_metric_vpn):
            return run.broker_series.find_sample(sample_num)
        raise PerfError(f'Unsupported metric_type: {metrics_type}')



class Run(CommonBase):

    def __init__(self, run_definition: RunDefinition, run_dir: str):
        CommonBase.__init__(self)
        self.run_definition = run_definition
        self.run_dir = run_dir
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

    def export_ping_series(self, list_metrics) -> arr.array:
        return self.ping_series.export_metrics(list_metrics)

    def export_broker_series(self, list_metrics) -> arr.array:
        return self.broker_series.export_metrics(list_metrics)

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

class BaseSeries(CommonBase):

    def __init__(self, run:Run):
        CommonBase.__init__(self)
        self.run = run

    def run_dir(self):
        return self.run.run_dir


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

    def find_sample(self, sample_num):
        try:
            return next(filter(lambda item: item.sample_num==sample_num, self.list_samples ))
        except StopIteration:
            raise PerfError(f'LatencyNodeLatencySeries - sample_num: {sample_num} not found')


class LatencyBrokerLatencySeries(BaseSeries):

    def __init__(self, run: Run):
        BaseSeries.__init__(self, run)
        self.list_samples = list()
        self.read_sample_files()

    def __str__(self):
        return f'[LatencyBrokerLatencySeries [len(list_stats): {len(self.list_samples)}]]'

    def read_sample_files(self):
        list_files = self.files_in_folder_by_pattern(self.run_dir(), perf_run_pattern_latency_broker_file)
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

    def find_sample(self, sample_num):
        try:
            return next(filter(lambda item: item.sample_num==sample_num, self.list_samples ))
        except StopIteration:
            raise PerfError(f'LatencyBrokerLatencySeries - sample_num: {sample_num} not found')

class PingSeries(BaseSeries):

    def __init__(self, run: Run):
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

    def find_sample(self, sample_num):
        try:
            return next(filter(lambda item: item.sample_num==sample_num, self.list_samples ))
        except StopIteration:
            raise PerfError(f'PingSeries - sample_num: {sample_num} not found')

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


class BaseSample():

    def __init__(self, run:Run ):
        self.run = run


class LatencySample(BaseSample):

    def __init__(self, run: Run, sample_json):
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


class PingSample(BaseSample):

    def __init__(self, run:Run, sample_json):
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


class BrokerSample(BaseSample):

    def __init__(self,run:Run, sample_json):
        BaseSample.__init__(self, run)
        self.read_metrics(sample_json)

    def export_all_metrics(self) -> list:
        return self.export_metrics(c_broker_all_metrics)

    def read_metrics(self, sample_json):
        self.run_id = sample_json["run_id"]
        self.ts_start = to_date(sample_json["sample_start_timestamp"], perf_latency_date_ts_pattern)
        self.sample_num = int(sample_json["sample_num"])
        self.metrics_type = sample_json["metrics_type"]
        self.broker_tx_msg_count = int(sample_json["metrics"]["dataTxMsgCount"])
        self.broker_rx_msg_count = int(sample_json["metrics"]["dataRxMsgCount"])
        self.broker_avg_tx_msg_rate = int(sample_json["metrics"]["averageTxMsgRate"])
        self.broker_avg_rx_msg_rate = int(sample_json["metrics"]["averageRxMsgRate"])
        self.broker_discard_tx_msg_count = int(sample_json["metrics"]["discardedRxMsgCount"])
        self.broker_discard_rx_msg_count = int(sample_json["metrics"]["discardedTxMsgCount"])

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