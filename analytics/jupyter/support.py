import logging
import datetime
import json
import glob
from jsonpath_ng import jsonpath, parse

def to_int(text:str) -> int:
    return int(text)


def to_float(text:str) -> float:
    return float(text)


def to_str(text:str) -> str:
    return text

def to_date(text:str) -> datetime:
    return datetime.datetime.strptime(text, '%Y-%m-%d %H:%M:%S+%f')

K_CONTEXT = "context"
K_TS = "ts"
K_SAMPLE_NUM = "sample_num"
K_50TH = "50th"
K_95TH = "95th"
K_99TH = "99th"
K_99_9TH = "99_9th"
K_AVERAGE = "average"
K_MAXIMUM = "maximum"
K_MINIMUM = "minimum"
K_STD_DEVIATION = "std_deviation"
K_PING_RTT_MAX = "rtt_max"
K_PING_RTT_MIN = "rtt_min"
K_PING_RTT_AVG = "rtt_avg"
K_PING_RTT_MDEV = "rtt_medv"

KEYS_LATENCY_METRIC =[K_50TH, K_95TH, K_99TH, K_99_9TH, K_MINIMUM, K_MAXIMUM, K_AVERAGE, K_STD_DEVIATION]

LAT_NODE__COLUMNS = {
    # "run_id": {"p": parse('run_id'), "convert": str},
    K_TS:  {"p": parse('sample_start_timestamp'), "convert": to_date},
    K_SAMPLE_NUM: {"p": parse('sample_num'), "convert": int},
    K_50TH: {"p": parse('metrics["latency_stats"].latency.latency_stats["50th_percentile_latency_usec"]'), "convert": int},
    K_95TH: {"p": parse('metrics["latency_stats"].latency.latency_stats["95th_percentile_latency_usec"]'), "convert": int},
    K_99TH: {"p": parse('metrics["latency_stats"].latency.latency_stats["99th_percentile_latency_usec"]'), "convert": int},
    K_99_9TH: {"p": parse('metrics["latency_stats"].latency.latency_stats["99.9th_percentile_latency_usec"]'), "convert": int},
    K_AVERAGE: {"p": parse('metrics["latency_stats"].latency.latency_stats["average_latency_for_subs_usec"]'), "convert": float},
    K_MAXIMUM: {"p": parse('metrics["latency_stats"].latency.latency_stats["maximum_latency_for_subs_usec"]'), "convert": float},
    K_MINIMUM: {"p": parse('metrics["latency_stats"].latency.latency_stats["minimum_latency_for_subs_usec"]'), "convert": float},
    K_STD_DEVIATION:  {"p": parse('metrics["latency_stats"].latency.latency_stats["standard_deviation_usec"]'), "convert": float}
}

LAT_BROKER__COLUMNS = {
    # "run_id": {"p": parse('run_id'), "convert": str},
    K_TS:  {"p": parse('sample_start_timestamp'), "convert": to_date},
    K_SAMPLE_NUM: {"p": parse('sample_num'), "convert": int},
    K_50TH: {"p": parse('metrics["latency_brokernode_stats"].latency.latency_stats["50th_percentile_latency_usec"]'), "convert": int},
    K_95TH: {"p": parse('metrics["latency_brokernode_stats"].latency.latency_stats["95th_percentile_latency_usec"]'), "convert": int},
    K_99TH: {"p": parse('metrics["latency_brokernode_stats"].latency.latency_stats["99th_percentile_latency_usec"]'), "convert": int},
    K_99_9TH: {"p": parse('metrics["latency_brokernode_stats"].latency.latency_stats["99.9th_percentile_latency_usec"]'), "convert": int},
    K_AVERAGE: {"p": parse('metrics["latency_brokernode_stats"].latency.latency_stats["average_latency_for_subs_usec"]'), "convert": float},
    K_MAXIMUM: {"p": parse('metrics["latency_brokernode_stats"].latency.latency_stats["maximum_latency_for_subs_usec"]'), "convert": float},
    K_MINIMUM: {"p": parse('metrics["latency_brokernode_stats"].latency.latency_stats["minimum_latency_for_subs_usec"]'), "convert": float},
    K_STD_DEVIATION:  {"p": parse('metrics["latency_brokernode_stats"].latency.latency_stats["standard_deviation_usec"]'), "convert": float}

}

PING__COLUMNS = {
    # "run_id": {"p": parse('run_id'), "convert": str},
    K_SAMPLE_NUM: {"p": parse('sample_num'), "convert": int},
    K_PING_RTT_AVG: {"p": parse('metrics.ping.rtt_avg.value'), "convert": float},
    K_PING_RTT_MAX: {"p": parse('metrics.ping.rtt_max.value'), "convert": float},
    K_PING_RTT_MIN: {"p": parse('metrics.ping.rtt_min.value'), "convert": float},
    K_PING_RTT_MDEV: {"p": parse('metrics.ping.rtt_mdev.value'), "convert": float},
}

logger = logging.getLogger("solace")


def extractLatency(metric_key, columns, stat_json):
    # print("DEBUG extract ", metric_key)
    return columns[metric_key]['p'].find(stat_json)[0].value

def parse_all_latency_node_as_metric_items(dir: str, context: str) -> list:
    search_pattern = dir+"/"+"latency_stats*"
    list_json_files = glob.glob(search_pattern)
    latency_list = []
    for json_file_name in list_json_files:
        logger.debug("processing file:",json_file_name)
        # print("processing file:",json_file_name)
        latency_list.extend(parse_latency_node_as_metric_items(json_file_name, context))
    return latency_list

def parse_all_latency_broker_as_metric_items(dir: str, context: str) -> list:
    search_pattern = dir+"/"+"latency_brokernode_stats*"
    list_json_files = glob.glob(search_pattern)
    latency_list = []
    for json_file_name in list_json_files:
        logger.debug("processing file:",json_file_name)
        # print("processing file:",json_file_name)
        latency_list.extend(parse_latency_broker_as_metric_items(json_file_name, context))
    return latency_list

def parse_all_ping(dir: str, context: str) -> list:
    search_pattern = dir+"/"+"ping-stats*"
    list_json_files = glob.glob(search_pattern)
    latency_list = []
    for json_file_name in list_json_files:
        logger.debug("processing file:",json_file_name)
        latency_list.append(parse_ping(json_file_name))
    for item in latency_list:
        item["context"]=context

    return sorted(latency_list, key = lambda row: row["sample_num"])

def parse_all_latency_broker_node(dir: str, context: str) -> list:
    search_pattern = dir+"/"+"latency_brokernode_stats*"
    list_json_files = glob.glob(search_pattern)
    latency_list = []
    for json_file_name in list_json_files:
        logger.debug("processing file:",json_file_name)
        latency_list.append(parse_latency_broker(json_file_name))
    for item in latency_list:
            item["context"]=context
    return sorted(latency_list, key = lambda row: row["sample_num"])

def parse_all_latency_node(dir: str, context: str) -> list:
    search_pattern = dir+"/"+"latency-stats*"
    logger.debug("Search pattern:",search_pattern)
    list_json_files = glob.glob(search_pattern)
    latency_list = []
    for json_file_name in list_json_files:
        logger.debug("processing file:",json_file_name)
        latency_list.append(parse_latency_node(json_file_name))
    for item in latency_list:
        item["context"]=context
    return sorted(latency_list, key = lambda row: row["sample_num"])


def parse_latency_node(stat_file_name: str) -> dict:
    result = dict()
    with open(stat_file_name) as stat_file:
        stat_json = json.load(stat_file)
        for key, v in LAT_NODE__COLUMNS.items():
            logger.debug('key',key)
            #print('key',key)
            result[key]=v['convert'](v['p'].find(stat_json)[0].value)
            logger.debug('Extracted value:', str(result[key]))
    return result

def parse_latency_broker(stat_file_name: str) -> dict:
    result = dict()
    with open(stat_file_name) as stat_file:
        stat_json = json.load(stat_file)
        for key, v in LAT_BROKER__COLUMNS.items():
            logger.debug('key',key)
            result[key]=v['convert'](v['p'].find(stat_json)[0].value)
            logger.debug('Extracted value:', str(result[key]))
    return result

def parse_ping(stat_file_name: str) -> dict:
    result = dict()
    with open(stat_file_name) as stat_file:
        stat_json = json.load(stat_file)
        for key, v in PING__COLUMNS.items():
            logger.debug('key',key)
            result[key]=v['convert'](v['p'].find(stat_json)[0].value)
            logger.debug('Extracted value:', str(result[key]))
    return result


def parse_latency_node_as_metric_items(stat_file_name: str, context:str) -> list:
    result = list()
    with open(stat_file_name) as stat_file:
        stat_json = json.load(stat_file)
        for key in KEYS_LATENCY_METRIC:
            #logger.debug('key',key)
            #print('key',key)
            list_item = dict()
            list_item[K_CONTEXT]=context
            list_item[K_TS]=extractLatency(K_TS,LAT_NODE__COLUMNS,stat_json)
            list_item[K_SAMPLE_NUM]=extractLatency(K_SAMPLE_NUM,LAT_NODE__COLUMNS,stat_json)
            list_item['metric']=key
            list_item['value']=extractLatency(key,LAT_NODE__COLUMNS,stat_json)
            result.append(list_item)
    return result

def parse_latency_broker_as_metric_items(stat_file_name: str, context:str) -> list:
    result = list()
    with open(stat_file_name) as stat_file:
        stat_json = json.load(stat_file)
        for key in KEYS_LATENCY_METRIC:
            #logger.debug('key',key)
            #print('key',key)
            list_item = dict()
            list_item[K_CONTEXT]=context
            list_item[K_TS]=extractLatency(K_TS,LAT_BROKER__COLUMNS,stat_json)
            list_item[K_SAMPLE_NUM]=extractLatency(K_SAMPLE_NUM,LAT_BROKER__COLUMNS,stat_json)
            list_item['metric']=key
            list_item['value']=extractLatency(key,LAT_BROKER__COLUMNS,stat_json)
            result.append(list_item)
    return result