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

    # def calculateClientConnectionAggregates(self, client_list: list):
    #     discard_rx_msg_count = 0
    #     discard_tx_msg_count = 0 
    #     rx_msg_count = 0
    #     tx_msg_count = 0
    #     for client in client_list:
    #         discard_rx_msg_count    += client["rxDiscardedMsgCount"]
    #         discard_tx_msg_count    += client["txDiscardedMsgCount"]
    #         rx_msg_count            += client["dataRxMsgCount"]
    #         tx_msg_count            += client["dataTxMsgCount"]
    #     return dict(
    #         rx_msg_count            = rx_msg_count,
    #         tx_msg_count            = tx_msg_count,
    #         discard_rx_msg_count    = discard_rx_msg_count,
    #         discard_tx_msg_count    = discard_tx_msg_count
    #     )    

    def calculateAggregates(self):
        vpn_discard_rx_msg_count = 0
        vpn_discard_tx_msg_count = 0 
        vpn_rx_msg_count         = 0
        vpn_tx_msg_count         = 0
        vpn_avg_tx_msg_rate      = 0
        vpn_avg_rx_msg_rate      = 0

        # consumers_rx_msg_count          = 0
        # consumers_tx_msg_count          = 0
        # consumers_discard_rx_msg_count  = 0
        # consumers_discard_tx_msg_count  = 0

        # publishers_rx_msg_count          = 0
        # publishers_tx_msg_count          = 0
        # publishers_discard_rx_msg_count  = 0
        # publishers_discard_tx_msg_count  = 0

        for sample in self.list_samples:
            vpn_discard_rx_msg_count    += sample.broker_discard_rx_msg_count
            vpn_discard_tx_msg_count    += sample.broker_discard_tx_msg_count
            vpn_rx_msg_count            += sample.broker_rx_msg_count
            vpn_tx_msg_count            += sample.broker_tx_msg_count
            vpn_avg_tx_msg_rate         += sample.broker_avg_tx_msg_rate
            vpn_avg_rx_msg_rate         += sample.broker_avg_rx_msg_rate
            
            # sample_consumers_aggregates = self.calculateClientConnectionAggregates(sample.getConsumerList())    
            # consumers_rx_msg_count          += sample_consumers_aggregates["rx_msg_count"]
            # consumers_tx_msg_count          += sample_consumers_aggregates["tx_msg_count"]
            # consumers_discard_rx_msg_count  += sample_consumers_aggregates["discard_rx_msg_count"]
            # consumers_discard_tx_msg_count  += sample_consumers_aggregates["discard_tx_msg_count"]  

            # sample_publishers_aggregates = self.calculateClientConnectionAggregates(sample.getPublisherList())
            # publishers_rx_msg_count          += sample_publishers_aggregates["rx_msg_count"]
            # publishers_tx_msg_count          += sample_publishers_aggregates["tx_msg_count"]
            # publishers_discard_rx_msg_count  += sample_publishers_aggregates["discard_rx_msg_count"]
            # publishers_discard_tx_msg_count  += sample_publishers_aggregates["discard_tx_msg_count"]  

        vpn=dict(
            fan_out_ratio           = vpn_tx_msg_count/vpn_rx_msg_count,
            rx_msg_count            = vpn_rx_msg_count,
            tx_msg_count            = vpn_tx_msg_count,
            discard_rx_msg_count    = vpn_discard_rx_msg_count,
            discard_tx_msg_count    = vpn_discard_tx_msg_count,
            avg_rx_msg_rate_per_sec = vpn_avg_rx_msg_rate/len(self.list_samples),
            avg_tx_msg_rate_per_sec = vpn_avg_tx_msg_rate/len(self.list_samples)
        )
        # consumers=dict(
        #     rx_msg_count            = consumers_rx_msg_count,
        #     tx_msg_count            = consumers_tx_msg_count,
        #     discard_rx_msg_count    = consumers_discard_rx_msg_count,
        #     discard_tx_msg_count    = consumers_discard_tx_msg_count
        # )
        # publishers=dict(
        #     rx_msg_count            = publishers_rx_msg_count,
        #     tx_msg_count            = publishers_tx_msg_count,
        #     discard_rx_msg_count    = publishers_discard_rx_msg_count,
        #     discard_tx_msg_count    = publishers_discard_tx_msg_count
        # )

        return dict(
            vpn=vpn
            # consumers=consumers,
            # publishers=publishers
        )

    def getOverviewAsMarkdown(self):

        # aggregates are most accurate from meta: end - start
        publisher_aggregates = self.run.run_meta.getPublisherAggregates()
        consumer_aggregates = self.run.run_meta.getConsumerAggregates()

        md = f"""
## Run Overview

Description: {self.run.run_meta.getRunSpecDescription()}

|  |Messages|Discarded|Rates (1/sec)|Fan Out|
|--|:------:|:-------:|:-----------:|:-----:|
|broker received:| {self.aggregates["vpn"]["rx_msg_count"]:,}  | {self.aggregates["vpn"]["discard_rx_msg_count"]:,}  | {self.aggregates["vpn"]["avg_rx_msg_rate_per_sec"]:,.0f} |1|
|broker sent:    | {self.aggregates["vpn"]["tx_msg_count"]:,}  | {self.aggregates["vpn"]["discard_tx_msg_count"]:,}  | {self.aggregates["vpn"]["avg_tx_msg_rate_per_sec"]:,.0f} |{self.aggregates["vpn"]["fan_out_ratio"]:.2f}|

- number of publishers: {len(self.run.run_meta.getEndTestPublisherList())}
- number of consumers: {len(self.run.run_meta.getEndTestConsumerList())}
- publishers:
    - from meta (end-start):
        - received: {publisher_aggregates["txMsgCount"]}
        - sent: {publisher_aggregates["rxMsgCount"]}
- consumers:
    - from meta (end-start):
        - received: {consumer_aggregates["txMsgCount"]}
        - sent: {consumer_aggregates["rxMsgCount"]}

        """
        
        return md

###
# The End.            