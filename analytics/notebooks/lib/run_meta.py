# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Jochen Traunecker (jochen.traunecker@solace.com)
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# ---------------------------------------------------------------------------------------------

from ._util import to_date
from .constants import *

class RunMeta():
    """ RunMeta """
    def __init__(self, metaJson):
        self.run_id = metaJson["meta"]["run_id"]
        self.run_name = metaJson["meta"]["run_name"]
        self.cloud_provider = metaJson["meta"]["cloud_provider"]
        self.infrastructure = metaJson["meta"]["infrastructure"]
        self.ts_run_start = to_date(metaJson["meta"]["run_start_time"], perf_meta_date_ts_pattern)
        self.ts_run_end = to_date(metaJson["meta"]["run_end_time"], perf_meta_date_ts_pattern)
        self.metaJson = metaJson

    def __str__(self):
        return f'[RunMeta: [infrastructure: {self.infrastructure}] [run_id: {self.run_id}] [run_duration: {self.run_duration()}]]'

    def run_duration(self):
        return self.ts_run_end - self.ts_run_start

    def getNumClientConnectionsAtStart(self):
        return self.metaJson["meta"]["client_connections"]["start_test"]["number"]

    def getNumClientConnectionsAtEnd(self):        
        return self.metaJson["meta"]["client_connections"]["end_test"]["number"]

    def getRunSpecDescription(self):
        return self.metaJson["meta"]["run_spec"]["general"]["description"]
    
    def getRunSpecParamsSampleDurationSecs(self):
        return self.metaJson["meta"]["run_spec"]["params"]["sample_duration_secs"]

    def getRunSpecParamsTotalNumSamples(self):
        return self.metaJson["meta"]["run_spec"]["params"]["total_num_samples"]

    def getRuncSpecLoadIsIncluded(self):
        return self.metaJson["meta"]["run_spec"]["load"]["include"]

    def getRunSpecLoadNumberOfPublishers(self) -> str:
        if not self.getRuncSpecLoadIsIncluded():
            return "n/a"    
        return f'{len(self.metaJson["meta"]["run_spec"]["load"]["publish"]["publishers"]):,}'

    def getRunSpecLoadPublishMsgPayloadSizeBytes(self) -> str:
        if not self.getRuncSpecLoadIsIncluded():
            return "n/a"    
        return f'{int(self.metaJson["meta"]["run_spec"]["load"]["publish"]["msg_payload_size_bytes"]):,}'

    def getRunSpecLoadPublishMsgRatePerSec(self) -> str:
        if not self.getRuncSpecLoadIsIncluded():
            return "n/a"
        return f'{int(self.metaJson["meta"]["run_spec"]["load"]["publish"]["msg_rate_per_second"]):,}'

    def getRunSpecLoadPublishTotalNumberOfTopics(self) -> str:
        if not self.getRuncSpecLoadIsIncluded():
            return "n/a"    
        list = self.metaJson["meta"]["run_spec"]["load"]["publish"]["publishers"]
        num = 0
        for elem in list:
            num += elem["number_of_topics"]
        return f'{num:,}'

    def getRunSpecLoadPublishTotalMsgRatePerSec(self) -> str:
        if not self.getRuncSpecLoadIsIncluded():
            return "n/a"    
        numPublishers = len(self.metaJson["meta"]["run_spec"]["load"]["publish"]["publishers"])
        rate = int(self.metaJson["meta"]["run_spec"]["load"]["publish"]["msg_rate_per_second"])
        return f'{(numPublishers * rate):,}'

    def getRunSpecLoadSubscribeTotalNumberOfConsumers(self):
        if not self.getRuncSpecLoadIsIncluded():
            return "n/a"    
        return len(self.metaJson["meta"]["run_spec"]["load"]["subscribe"]["consumers"])

    def getBrokerNode(self):
        return self.metaJson["meta"]["nodes"]["broker_nodes"][0]

    def getBrokerNodeSpec(self):
        node = self.getBrokerNode()
        if self.cloud_provider == "azure":
            return f"size: {node['size']}"
        elif self.cloud_provider == "aws":
            return f"type: {node['node_details']['instance_type']}, cores: {node['node_details']['cpu_core_count']}"
        else:    
            return f"ERROR: unknown node spec for cloud_provider:{self.cloud_provider}"

    def getMonitorNode(self):
        return self.metaJson["meta"]["nodes"]["sdkperf_nodes"][0]

    def getMonitorNodeSpec(self):
        node = self.getMonitorNode()
        if self.cloud_provider == "azure":
            return f"size: {node['size']}"
        elif self.cloud_provider == "aws":
            return f"type: {node['node_details']['instance_type']}, cores: {node['node_details']['cpu_core_count']}"
        else:    
            return f"ERROR: unknown node spec for cloud_provider:{self.cloud_provider}"

    def getPublisherNodeSpec(self):
        return self.getMonitorNodeSpec()

    def getNumPublisherNodes(self):
        return "TODO: needs inventory in meta"

    def getConsumerNodeSpec(self):
        return self.getMonitorNodeSpec()

    def getNumConsumerNodes(self):
        return "TODO: needs inventory in meta"

    """ Run Spec General """
    def getRunSpecGeneral(self):
        return self.metaJson["meta"]["run_spec"]["general"]

    """ Monitor Latency """
    def getRunSpecMonitorLatencyLpm(self):
        if not self.getRuncSpecMonitorLatencyBrokerNodeIsIncluded() and not self.getRuncSpecMonitorLatencyLatencyNodeIsIncluded():
            return "n/a"  
        return self.metaJson["meta"]["run_spec"]["monitors"]["latency"]["lpm"]

    def getRunSpecMonitorLatencyMsgPayloadSizeBytes(self) -> str:
        if not self.getRuncSpecMonitorLatencyBrokerNodeIsIncluded() and not self.getRuncSpecMonitorLatencyLatencyNodeIsIncluded():
            return "n/a"  
        return f'{int(self.metaJson["meta"]["run_spec"]["monitors"]["latency"]["msg_payload_size_bytes"]):,}'

    def getRunSpecMonitorLatencyMsgRatePerSec(self) -> str:
        if not self.getRuncSpecMonitorLatencyBrokerNodeIsIncluded() and not self.getRuncSpecMonitorLatencyLatencyNodeIsIncluded():
            return "n/a"  
        return f'{int(self.metaJson["meta"]["run_spec"]["monitors"]["latency"]["msg_rate_per_second"]):,}'

    """ Monitor Latency Latency Node """
    def getRuncSpecMonitorLatencyLatencyNodeIsIncluded(self):
        return self.metaJson["meta"]["run_spec"]["monitors"]["latency"]["sdkperf_node_to_broker"]["include"]

    """ Monitor Latency Broker Node """
    def getRuncSpecMonitorLatencyBrokerNodeIsIncluded(self):
        return self.metaJson["meta"]["run_spec"]["monitors"]["latency"]["broker_node_to_broker"]["include"]

    """ Monitor Ping """
    def getRuncSpecMonitorPingIsIncluded(self):
        return self.metaJson["meta"]["run_spec"]["monitors"]["ping"]["include"]

    """ Monitor Vpn """
    def getRuncSpecMonitorVpnIsIncluded(self):
        return self.metaJson["meta"]["run_spec"]["monitors"]["vpn_stats"]["include"]

    def getAsMarkdown(self):
        md = f"""

## Run Settings
* Description: "{self.getRunSpecDescription()}"
* Test Spec: "description - todo" ({self.getRunSpecGeneral()["test_spec_name"]})

|General|                                                             | | Infrastructure            |                                                                            |      |   |  
|:--|:----------------------------------------------------------------|-|:--------------------------|:---------------------------------------------------------------------------|:-----|:--|
|Infrastructure: |{self.infrastructure}                               | |Broker Node:               |nodes: 1<br/>spec: {self.getBrokerNodeSpec()}                               |      |   |
|Run name: |{self.run_name}                                           | |Load<br/>Publisher Nodes:  |nodes: {self.getNumPublisherNodes()}<br/>spec:{self.getPublisherNodeSpec()} |      |   |
|Run Id: |{self.run_id}                                               | |Load<br/>Consumer Nodes:   |nodes: {self.getNumConsumerNodes()} <br/>spec:{self.getConsumerNodeSpec()}  |      |   |
|Run Start: |{self.ts_run_start}                                      | |Monitor Node:              |nodes: 1 <br/>spec:{self.getMonitorNodeSpec()}  |      |   |
|Run End: |{self.ts_run_end}|||
|Run Duration: |{self.run_duration()}|||
|Sample Duration (secs): |{self.getRunSpecParamsSampleDurationSecs()}|||
|Number of Samples:|{self.getRunSpecParamsTotalNumSamples()}|||


|Load|                                                                          | | Monitors   |                              |                                                                 |  
|:--|:--------------------------------------------------------------------------|-|:-----------|:-----------------------------|:----------------------------------------------------------------|
|Included:              |**{self.getRuncSpecLoadIsIncluded()}**                 | |**Latency** |                              |                                                                 |  
|Connections @ start:   |{self.getNumClientConnectionsAtStart()}                | | |Latency Node to Broker Node - included:  |**{self.getRuncSpecMonitorLatencyLatencyNodeIsIncluded()}**      |    
|Connections @ end:     |{self.getNumClientConnectionsAtEnd()}                  | | |Broker Node to Broker Node - included:   |**{self.getRuncSpecMonitorLatencyBrokerNodeIsIncluded()}**       |      
|Publishers:            |{self.getRunSpecLoadNumberOfPublishers()}              | | |Payload (bytes):                         |{self.getRunSpecMonitorLatencyMsgPayloadSizeBytes()}             |      
| - Payload (bytes):    |{self.getRunSpecLoadPublishMsgPayloadSizeBytes()}      | | |Rate (1/sec):                            |{self.getRunSpecMonitorLatencyMsgRatePerSec()}                   |      
| - Rate (1/sec):       |{self.getRunSpecLoadPublishTotalMsgRatePerSec()}       | |**Ping**       | included:                 |**{self.getRuncSpecMonitorPingIsIncluded()}**                    |  
| - Topics:             |{self.getRunSpecLoadPublishTotalNumberOfTopics()}      | |**Broker VPN** | included:                 |**{self.getRuncSpecMonitorVpnIsIncluded()}**                     |  
|Consumers:             |{self.getRunSpecLoadSubscribeTotalNumberOfConsumers()} | 
|                       |                                                       | 
            """
        return md    

###
# The End.        