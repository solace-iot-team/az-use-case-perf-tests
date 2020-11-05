# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Jochen Traunecker (jochen.traunecker@solace.com)
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# ---------------------------------------------------------------------------------------------

import json

from .base_series import BaseSeries
from .broker_sample import BrokerSample
from .constants import *
from .perf_error import PerfError


import logging

class BrokerSeries(BaseSeries):

    def __init__(self, run):
        BaseSeries.__init__(self, run)
        self.list_samples = list()
        self.aggregates = dict()
        self.read_sample_files()

    def read_sample_files(self):
        list_files = self.files_in_folder_by_pattern(self.run_dir(), perf_run_pattern_vpn_performance_file)
        for file_name in list_files:
            with open(file_name) as sample_file:
                self.list_samples.append(BrokerSample(run=self.run, sample_json=json.load(sample_file)))
        self.aggregates.update(self.calculateAggregates())

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

    def calculateAggregates(self):
        discard_rx_msg_count = 0
        discard_tx_msg_count = 0 
        rx_msg_count = 0
        tx_msg_count = 0
        avg_tx_msg_rate = 0
        avg_rx_msg_rate = 0
        for sample in self.list_samples:
            discard_rx_msg_count += sample.broker_discard_rx_msg_count
            discard_tx_msg_count += sample.broker_discard_tx_msg_count
            rx_msg_count += sample.broker_rx_msg_count
            tx_msg_count += sample.broker_tx_msg_count
            avg_tx_msg_rate += sample.broker_avg_tx_msg_rate
            avg_rx_msg_rate += sample.broker_avg_rx_msg_rate
   
        return dict(
            fan_out_ratio=tx_msg_count/rx_msg_count,
            rx_msg_count=rx_msg_count,
            tx_msg_count=tx_msg_count,
            discard_rx_msg_count=discard_rx_msg_count,
            discard_tx_msg_count=discard_tx_msg_count,
            avg_rx_msg_rate_per_sec=avg_rx_msg_rate/len(self.list_samples),
            avg_tx_msg_rate_per_sec=avg_tx_msg_rate/len(self.list_samples)
        )

    def getChecksAsMarkdown(self):

        logging.debug('type(aggregates)={}'.format(type(self.aggregates)))
        logging.debug("aggregates={}".format(self.aggregates))



        md = f"""
## Run Overview

**Avg Fan-out ratio: {self.aggregates["fan_out_ratio"]:.2f} to 1**

Number of messages:
* received: {self.aggregates["rx_msg_count"]:,}
* sent: {self.aggregates["tx_msg_count"]:,}

Number discarded messages: 
* received: {self.aggregates["discard_rx_msg_count"]:,}
* sent: {self.aggregates["discard_tx_msg_count"]:,}

Avg message rates (1/sec):
* received: {self.aggregates["avg_rx_msg_rate_per_sec"]:,.0f}
* sent: {self.aggregates["avg_tx_msg_rate_per_sec"]:,.0f}


  ---      

        """
        
        return md

###
# The End.            