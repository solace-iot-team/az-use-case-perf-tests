# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Jochen Traunecker (jochen.traunecker@solace.com)
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# ---------------------------------------------------------------------------------------------

from ._util import to_date
from .constants import *
from .perf_error import PerfError

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

    def getSolacePubSubInfo(self):
        return self.metaJson["meta"]["solace_pubsub_image"]

    def getEnvRegion(self):
        return self.metaJson["meta"]["env"]["region"]

    def getEnvZone(self):
        return self.metaJson["meta"]["env"]["zone"]

    """ Client Connections """

    def getNumClientConnectionsAtStart(self):
        return len(self.getStartTestConsumerList()) + len(self.getStartTestPublisherList())

    def getNumClientConnectionsAtEnd(self):        
        return len(self.getEndTestConsumerList()) + len(self.getEndTestPublisherList()) 

    def getStartTestPublisherList(self):
        return self.metaJson["meta"]["client_connections"]["start_test"]["publisher_list"]

    def getEndTestPublisherList(self):
        return self.metaJson["meta"]["client_connections"]["end_test"]["publisher_list"]

    def getStartTestConsumerList(self):
        return self.metaJson["meta"]["client_connections"]["start_test"]["consumer_list"]

    def getEndTestConsumerList(self):
        return self.metaJson["meta"]["client_connections"]["end_test"]["consumer_list"]

    def _getClientListAggregates(self, client_list):
        aggregates=dict(
            rxDiscardedMsgCount=0,
            rxMsgCount=0,
            txDiscardedMsgCount=0,
            txMsgCount=0
        )
        for client in client_list:
            aggregates['rxDiscardedMsgCount'] += client['rxDiscardedMsgCount']
            aggregates['rxMsgCount'] += client['dataRxMsgCount']
            aggregates['txDiscardedMsgCount'] += client['txDiscardedMsgCount']
            aggregates['txMsgCount'] += client['dataTxMsgCount']

        return aggregates    

    def getPublisherAggregates(self):
        end     = self._getClientListAggregates(self.getEndTestPublisherList())
        start   = self._getClientListAggregates(self.getStartTestPublisherList())
        return dict(
            rxDiscardedMsgCount = end['rxDiscardedMsgCount'] - start['rxDiscardedMsgCount'],
            rxMsgCount          = end['rxMsgCount'] - start['rxMsgCount'],
            txDiscardedMsgCount = end['txDiscardedMsgCount'] - start['txDiscardedMsgCount'],
            txMsgCount          = end['txMsgCount'] - start['txMsgCount']
        )

    def getConsumerAggregates(self):
        end     = self._getClientListAggregates(self.getEndTestConsumerList())
        start   = self._getClientListAggregates(self.getStartTestConsumerList())
        return dict(
            rxDiscardedMsgCount = end['rxDiscardedMsgCount'] - start['rxDiscardedMsgCount'],
            rxMsgCount          = end['rxMsgCount'] - start['rxMsgCount'],
            txDiscardedMsgCount = end['txDiscardedMsgCount'] - start['txDiscardedMsgCount'],
            txMsgCount          = end['txMsgCount'] - start['txMsgCount']
        )

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

    def getNodeSpec(self, node): 
        if self.cloud_provider == "azure":
            return f"size: {node['size']}"
        elif self.cloud_provider == "aws":
            return f"type: {node['node_details']['instance_type']}, cores: {node['node_details']['cpu_core_count']}"
        else:    
            return f"ERROR: unknown node spec for cloud_provider:{self.cloud_provider}"

    def getNumBrokerNodes(self):
        return len(self.metaJson["meta"]["nodes"]["broker_nodes"])

    # def getBrokerNode(self, public_ip):
    #     broker_nodes = self.metaJson["meta"]["nodes"]["broker_nodes"]
    #     # there can only be 1
    #     if len(broker_nodes) != 1:
    #         raise PerfError("[ERROR] - found more than 1 broker_node in nodes")
    #     if broker_nodes[0]["public_ip"] != public_ip:
    #         raise PerfError("[ERROR] - broker node public ip does not match inventory public_ip")
    #     return broker_nodes[0]

    def getBrokerNodeSpec(self):
        # public_ip = self.metaJson["meta"]["inventory"]["all"]["hosts"]["broker_centos"]["ansible_host"]
        # node = self.getBrokerNode(public_ip)
        node = self.metaJson["meta"]["nodes"]["broker_nodes"][0]
        return self.getNodeSpec(node)

    def getMonitorNodeSpec(self):
        node = self.metaJson["meta"]["nodes"]["latency_nodes"][0]
        return self.getNodeSpec(node)

    def getNumPublisherNodes(self):
        #  -1:NOT_A_HOST
        return len(self.metaJson["meta"]["inventory"]["sdkperf_publishers"]["hosts"])-1

    def getPublisherNodeSpec(self):
        node = self.metaJson["meta"]["nodes"]["publisher_nodes"][0]
        return self.getNodeSpec(node)

    def getNumConsumerNodes(self):
        #  -1:NOT_A_HOST
        return len(self.metaJson["meta"]["inventory"]["sdkperf_consumers"]["hosts"])-1

    def getConsumerNodeSpec(self):
        node = self.metaJson["meta"]["nodes"]["consumer_nodes"][0]
        return self.getNodeSpec(node)

    """ Run Spec General """
    def getRunSpecGeneral(self):
        return self.metaJson["meta"]["run_spec"]["general"]

    """ Monitor Latency """
    def getNumMonitorNodes(self):
        return len(self.metaJson["meta"]["inventory"]["sdkperf_latency"]["hosts"])

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

    def getUseCaseAsMarkdown(self):
        md = f"""
## Use Case: {self.metaJson["meta"]["run_spec"]["general"]["use_case"]["display_name"]} ({self.metaJson["meta"]["run_spec"]["general"]["use_case"]["name"]})

Test Specification: 
{self.getRunSpecGeneral()["test_spec"]["descr"]}.
({self.getRunSpecGeneral()["test_spec"]["name"]})
        """
        return md


    def getAsMarkdown(self):
        md = f"""

## Run Settings
* Description: "{self.getRunSpecDescription()}"

|General                    |                                                   | | Infrastructure:           | cloud provider:{self.cloud_provider}                                        |      |   |  
|:--------------------------|:--------------------------------------------------|-|:--------------------------|:----------------------------------------------------------------------------|:-----|:--|
|Run name:                  |{self.run_name}                                    | |{self.infrastructure}      |region: {self.getEnvRegion()}, zone: {self.getEnvZone()}                     |      |   |                                              
|Run Id:                    |{self.run_id}                                      | |Broker Node:               |nodes: {self.getNumBrokerNodes()}<br/>{self.getBrokerNodeSpec()}             |      |   |
|Run Start:                 |{self.ts_run_start}                                | |Load<br/>Publisher Nodes:  |nodes: {self.getNumPublisherNodes()}<br/>{self.getPublisherNodeSpec()}       |      |   |
|Run End:                   |{self.ts_run_end}                                  | |Load<br/>Consumer Nodes:   |nodes: {self.getNumConsumerNodes()} <br/>{self.getConsumerNodeSpec()}        |      |   |
|Run Duration:              |{self.run_duration()}                              | |Monitor Node:              |nodes: {self.getNumMonitorNodes()} <br/>{self.getMonitorNodeSpec()}          |      |   |  
|Sample Duration (secs):    |{self.getRunSpecParamsSampleDurationSecs()}        | |Solace PubSub+             | {self.getSolacePubSubInfo()}                                                |      |   | 
|Number of Samples:         |{self.getRunSpecParamsTotalNumSamples()}           | |                           |                                                                             |      |   | 


|Load|                                                                          | | Monitors   |                              |                                                                 |  
|:--|:--------------------------------------------------------------------------|-|:-----------|:-----------------------------|:----------------------------------------------------------------|
|Included:              |**{self.getRuncSpecLoadIsIncluded()}**                 | |**Latency** |                              |                                                                 |  
|Connections @ start:   |{self.getNumClientConnectionsAtStart()}                | | |Latency Node to Broker Node - included:  |**{self.getRuncSpecMonitorLatencyLatencyNodeIsIncluded()}**      |    
|Connections @ end:     |{self.getNumClientConnectionsAtEnd()}                  | | |Broker Node to Broker Node - included:   |**{self.getRuncSpecMonitorLatencyBrokerNodeIsIncluded()}**       |      
|Publishers:            |{self.getRunSpecLoadNumberOfPublishers()}              | | |Payload (bytes):                         |{self.getRunSpecMonitorLatencyMsgPayloadSizeBytes()}             |      
| - Payload (bytes):    |{self.getRunSpecLoadPublishMsgPayloadSizeBytes()}      | | |Rate (1/sec):                            |{self.getRunSpecMonitorLatencyMsgRatePerSec()}                   |      
| - Rate (1/sec):       |{self.getRunSpecLoadPublishTotalMsgRatePerSec()}       | |**Ping**       | included:                 |**{self.getRuncSpecMonitorPingIsIncluded()}**                    |  
| - Topics:             |{self.getRunSpecLoadPublishTotalNumberOfTopics()}      | |**Broker VPN** | included:                 |**{self.getRuncSpecMonitorVpnIsIncluded()}**                     |  
|Consumers:             |{self.getRunSpecLoadSubscribeTotalNumberOfConsumers()} | |               |                           |                                                                 |   

            """
        return md    

###
# The End.        