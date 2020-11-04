import glob
import os.path
from os import path

from .common_base import CommonBase
from .constants import *
from .perf_error import PerfError
from .run import Run
from .run_result_location import RunResultLocation


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
        #just metadata read
        self._processed_samples = False

    def process_run_samples(self, process_distinct_latency_samples:bool=True):
        rootExists = self._check_root_folder_in_run_location()
        self._process_distinct_latency_samples = process_distinct_latency_samples
        if not rootExists:
            raise SystemExit(f'[FATAL] [EXITING] Root folder does not exist:{self._location.root_folder}')
        for run_dir in self._read_list_runs():
            self._list_runs.append(Run(self,run_dir))
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

    def find_run(self, run_id, read_samples:bool=True):
        """
        Searches for run with run_id

        :param run_id:
        :param read_samples: read also the latencies before handing over the run
        :return: Run
        :raise: PerfError: if run_id was not found
        """
        self._check_processed_sampled()
        try:
            run =  next(filter(lambda item: item.run_meta.run_id==run_id, self._list_runs))
            if read_samples:
                #idempotent - samples will be read just once
                run.read_samples()
            return run
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
        #idempotent - samples will be read just once
        run.read_samples()
        if (metrics_type==c_sample_metric_type_latency_node):
            return run.latency_node_latency_series.find_sample(sample_num)
        if (metrics_type==c_sample_metric_type_latency_broker):
            return run.broker_node_latency_series.find_sample(sample_num)
        if (metrics_type==c_sample_metric_type_ping):
            return run.ping_series.find_sample(sample_num)
        if (metrics_type==c_sample_metric_vpn):
            return run.broker_series.find_sample(sample_num)
        raise PerfError(f'Unsupported metric_type: {metrics_type}')