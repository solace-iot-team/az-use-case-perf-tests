# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Jochen Traunecker (jochen.traunecker@solace.com)
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# ---------------------------------------------------------------------------------------------

from ._constants import *
from ._util import *
from .base_sample import BaseSample


class BrokerSample(BaseSample):

    def __init__(self,run, sample_json):
        BaseSample.__init__(self, run)
        # self.sampleJson = sample_json
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
        self.clients = sample_json["client_connections"]["clients"]
        self.client_connection_details = sample_json["client_connections"]["client_connection_details"]

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


### 
# The End.              