import perfmodel

#define run result location
location = perfmodel.RunResultLocation("<path/to/analytics>/analytics/testresults/azure.1-auto-standalone")
# location = perfmodel.RunResultLocation("/Users/jt/myproject/solace/azure-performance/solace-azure-performance/github/az-use-case-perf-tests/analytics/testresults/azure.1-auto-standalone")

#configure RunDefinition
runDefinition = perfmodel.RunDefinition(location)
#Process all sample files
#including all distinct latency samples within each sample file
runDefinition.process_run_samples(process_distinct_latency_samples=True)

#retrieve all Runs
for item in runDefinition.all_runs():
    print(str(item))

#get the first run
run_item = runDefinition.all_runs()[0]

#find a sample based on run-id, metric-type and sample number
sample = runDefinition.find_sample("2020-10-23-16-21-43",perfmodel.c_sample_metric_type_latency_node, 2)
print(str(sample))
#export all latency metrics
all_metrics = sample.export_all_metrics()
#export specific metric
specific_metric = sample.export_metrics([perfmodel.k_latency_50th])