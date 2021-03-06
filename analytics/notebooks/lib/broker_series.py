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

    def getSeriesOfListOfClientConnectionDetails(self):
        """Returns a list of dicts"""

        result_list = list()

        for sample in sorted(self.list_samples, key=lambda sample: sample.sample_num):

            entry=dict(
                sample_num=sample.sample_num,
                client_connection_details=sample.client_connection_details
            )

            result_list.append(entry)

        return result_list


    def calculateAggregates(self):
        vpn_discard_rx_msg_count = 0
        vpn_discard_tx_msg_count = 0
        vpn_rx_msg_count         = 0
        vpn_tx_msg_count         = 0
        vpn_avg_tx_msg_rate      = 0
        vpn_avg_rx_msg_rate      = 0
        fan_out_ratio            = float(0)

        if self.list_samples and len(self.list_samples) > 0:
            #  NOTE: last stat contains the aggregates already
            sample = self.list_samples[-1]
            vpn_discard_rx_msg_count    = sample.broker_discard_rx_msg_count
            vpn_discard_tx_msg_count    = sample.broker_discard_tx_msg_count
            vpn_rx_msg_count            = sample.broker_rx_msg_count
            vpn_tx_msg_count            = sample.broker_tx_msg_count
            vpn_avg_tx_msg_rate         = sample.broker_avg_tx_msg_rate
            vpn_avg_rx_msg_rate         = sample.broker_avg_rx_msg_rate

        if vpn_rx_msg_count > 0:
            fan_out_ratio           = vpn_tx_msg_count/vpn_rx_msg_count

        vpn=dict(
            fan_out_ratio           = fan_out_ratio,
            rx_msg_count            = vpn_rx_msg_count,
            tx_msg_count            = vpn_tx_msg_count,
            discard_rx_msg_count    = vpn_discard_rx_msg_count,
            discard_tx_msg_count    = vpn_discard_tx_msg_count,
            avg_rx_msg_rate_per_sec = vpn_avg_rx_msg_rate,
            avg_tx_msg_rate_per_sec = vpn_avg_tx_msg_rate
        )
        return dict(
            vpn=vpn
        )

    def getOverviewAsMarkdown(self):

        # aggregates are most accurate from meta: end - start
        publisher_aggregates = self.run.run_meta.getPublisherAggregates()
        consumer_aggregates = self.run.run_meta.getConsumerAggregates()
        load_fan_out_ratio = 0.0
        if publisher_aggregates["rxMsgCount"] > 0:
            load_fan_out_ratio  = consumer_aggregates["txMsgCount"] / publisher_aggregates["rxMsgCount"]


        md = f"""
## Run Metrics Summary

Description: {self.run.run_meta.getRunSpecDescription()}

|PubSub+ Broker*  |Messages|Discarded|Rate** (1/sec)    |Fan Out|
|:---------------|:------:|:-------:|:-----------------:|:-----:|
|received:| {self.aggregates["vpn"]["rx_msg_count"]:,}  | {self.aggregates["vpn"]["discard_rx_msg_count"]:,}  | {self.aggregates["vpn"]["avg_rx_msg_rate_per_sec"]:,.0f} |1|
|sent:    | {self.aggregates["vpn"]["tx_msg_count"]:,}  | {self.aggregates["vpn"]["discard_tx_msg_count"]:,}  | {self.aggregates["vpn"]["avg_tx_msg_rate_per_sec"]:,.0f} |{self.aggregates["vpn"]["fan_out_ratio"]:.2f}|

|Load***                                                             |Messages                               |Discarded                                       |Rate (1/sec)                                  |Fan Out                     |
|:-------------------------------------------------------------------|:-------------------------------------:|:----------------------------------------------:|:--------------------------------------------:|:--------------------------:|
|publishers ({len(self.run.run_meta.getEndTestPublisherList())})     |{publisher_aggregates["rxMsgCount"]:,} |{publisher_aggregates["rxDiscardedMsgCount"]:,} |{publisher_aggregates["meanRxMsgRate"]:,.0f}  |1                           |
|consumers ({len(self.run.run_meta.getEndTestConsumerList())})       |{consumer_aggregates["txMsgCount"]:,}  |{consumer_aggregates["txDiscardedMsgCount"]:,}  |{consumer_aggregates["meanTxMsgRate"]:,.0f}   |{load_fan_out_ratio:.2f}    |

_*: Note: Stats from broker vpn. Include latency probes, consumers, and publishers. Snapshot taken after tests complete (no traffic) and excluding publishers._

_**: Note: Average rate over 60 seconds._

_***: Note: Stats from publisher & consumer client connections, while both sets are still running. Therefore, message numbers may not tally up exactly._

        """

        return md

###
# The End.
