# for internal testing only

from lib import run_definition
from lib import run_result_location
from lib import constants
from lib import run
from lib import run_analytics

import pandas as pd

#define run result location
location = run_result_location.RunResultLocation("../testresults/azure.1-auto-standalone")
run_id = "2020-11-02-18-36-10"
#configure RunDefinition
runDefinition = run_definition.RunDefinition(location)
#Process all sample files
#including all distinct latency samples within each sample file
runDefinition.process_run_samples(process_distinct_latency_samples=True)

#retrieve all Runs
for run in runDefinition.all_runs():
    print(str(run))

#get the first run
run_item = runDefinition.all_runs()[0]
run_item.read_samples()

run_item.export_latency_node_delta_index_latencies(lambda lat: lat > 1000)
run_item.export_broker_node_delta_index_latencies(lambda lat: lat > 1000)

result = run_item.export_latency_node_series_length_latencies(lambda lat: lat > 1000)
result = run_item.export_broker_node_series_length_latencies(lambda lat: lat > 1000)
#find a sample based on run-id, metric-type and sample number
sample = runDefinition.find_sample(run_id,constants.c_sample_metric_type_latency_node, 2)
print(str(sample))
delta_index = sample.export_delta_index_latencies(lambda lat: lat > 1000)


#export all latency metrics
all_metrics = sample.export_all_metrics()
#export specific metric
specific_metric = sample.export_metrics([constants.k_latency_50th])

s1 = run_item.export_latency_node_series_latencies()
s2 = run_item.export_broker_node_series_latencies()

s3 = run_item.export_latency_node_distinct_latencies_per_sample()
s4 = run_item.export_broker_node_distinct_latencies_per_sample()

latency_dict = run_item.export_latency_node_distinct_latencies_per_sample()

ra = run_analytics.RunAnalytics(run_item)
x = ra.export_latency_node_series_latencies_metrics()
x2 = ra.export_latency_node_series_latencies_metrics_as_dataframe()
print("end")