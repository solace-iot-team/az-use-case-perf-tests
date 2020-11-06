# Analytics : Auto-Run

Exmaples for running analytics and creating reports for test results.

## Customize Run Script

Create a copy or modify:

````bash
vi run.auto.1.fg.sh
# customize settings
````

### Test Results - Input
````bash
export TEST_RESULTS_DIR="$projectHome/uc-non-persistent/test-results/stats"
````

### Analysis Reports - Output
````bash
export ANALYSIS_OUT_DIR="$projectHome/uc-non-persistent/test-results/analysis"
````

### Infrastructure Ids

````bash
infrastructureIds=(
  "azure.1-auto-standalone"
  "azure.2-auto-standalone"
  "aws.1-auto-standalone"
)
````

Scripts loops through `infrastructureIds` to looks for test results in `$TEST_RESULTS_DIR/$infrastructureId`. 

---
The End.
