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

    def getEnvRegion(self):
        return self.metaJson["meta"]["env"]["region"]

    def getEnvZone(self):
        return self.metaJson["meta"]["env"]["zone"]

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

    def getNumBrokerNodes(self):
        return len(self.metaJson["meta"]["nodes"]["broker_nodes"])

    def getBrokerNodeDetails(self, public_ip):
        broker_nodes = self.metaJson["meta"]["nodes"]["broker_nodes"]
        # there can only be 1
        if len(broker_nodes) != 1:
            raise PerfError("[ERROR] - found more than 1 broker_node in nodes")
        if broker_nodes[0]["public_ip"] != public_ip:
            raise PerfError("[ERROR] - broker node public ip does not match inventory public_ip")
        return broker_nodes[0]

    def getBrokerNodeSpec(self):
        public_ip = self.metaJson["meta"]["inventory"]["all"]["hosts"]["broker_centos"]["ansible_host"]
        node = self.getBrokerNodeDetails(public_ip)
        if self.cloud_provider == "azure":
            return f"size: {node['size']}"
        elif self.cloud_provider == "aws":
            return f"type: {node['node_details']['instance_type']}, cores: {node['node_details']['cpu_core_count']}"
        else:    
            return f"ERROR: unknown node spec for cloud_provider:{self.cloud_provider}"

    def getMonitorNodeDetails(self, public_ip):
        sdkperf_nodes = self.metaJson["meta"]["nodes"]["sdkperf_nodes"]
        return [x for x in sdkperf_nodes if x["public_ip"] == public_ip][0]

    def getMonitorNodeSpec(self):
        sdkperf_latency_hosts = self.metaJson["meta"]["inventory"]["sdkperf_latency"]["hosts"]
        # assuming here there is only 1
        if len(sdkperf_latency_hosts) != 1:
            raise PerfError("[ERROR] - found more than 1 sdkperf_latency host in inventory")
        monitor_node_public_ip = sdkperf_latency_hosts[list(sdkperf_latency_hosts)[0]]["ansible_host"]
        node = self.getMonitorNodeDetails(monitor_node_public_ip)
        if self.cloud_provider == "azure":
            return f"size: {node['size']}"
        elif self.cloud_provider == "aws":
            return f"type: {node['node_details']['instance_type']}, cores: {node['node_details']['cpu_core_count']}"
        else:    
            return f"ERROR: unknown node spec for cloud_provider:{self.cloud_provider}"

    def getPublisherNodeSpec(self):
        # lazy, assuming they are the same
        return self.getMonitorNodeSpec()

    def getNumPublisherNodes(self):
        return len(self.metaJson["meta"]["inventory"]["sdkperf_publishers"]["hosts"])

    def getConsumerNodeSpec(self):
        # lazy, assuming they are the same
        return self.getMonitorNodeSpec()

    def getNumConsumerNodes(self):
        return len(self.metaJson["meta"]["inventory"]["sdkperf_consumers"]["hosts"])

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
## Use Case: {self.metaJson["meta"]["use_case"]}
        """
        return md


    def getAsMarkdown(self):
        md = f"""

## Run Settings
* Description: "{self.getRunSpecDescription()}"
* test spec id: ({self.getRunSpecGeneral()["test_spec_name"]})

|General                    |                                                   | | Infrastructure:           | cloud provider:{self.cloud_provider}                                        |      |   |  
|:--------------------------|:--------------------------------------------------|-|:--------------------------|:----------------------------------------------------------------------------|:-----|:--|
|Run name:                  |{self.run_name}                                    | |{self.infrastructure}      |region: {self.getEnvRegion()}, zone: {self.getEnvZone()}                     |      |   |                                              
|Run Id:                    |{self.run_id}                                      | |Broker Node:               |nodes: {self.getNumBrokerNodes()}<br/>spec: {self.getBrokerNodeSpec()}       |      |   |
|Run Start:                 |{self.ts_run_start}                                | |Load<br/>Publisher Nodes:  |nodes: {self.getNumPublisherNodes()}<br/>spec:{self.getPublisherNodeSpec()}  |      |   |
|Run End:                   |{self.ts_run_end}                                  | |Load<br/>Consumer Nodes:   |nodes: {self.getNumConsumerNodes()} <br/>spec:{self.getConsumerNodeSpec()}   |      |   |
|Run Duration:              |{self.run_duration()}                              | |Monitor Node:              |nodes: {self.getNumMonitorNodes()} <br/>spec:{self.getMonitorNodeSpec()}     |      |   |  
|Sample Duration (secs):    |{self.getRunSpecParamsSampleDurationSecs()}        | |                           |                                                                             |      |   | 
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