# Tests

## Run all tests

````bash
export UC_NON_PERSISTENT_INFRASTRUCTURE={cloud-provider}.{infrastructure-id}
# for example:
export UC_NON_PERSISTENT_INFRASTRUCTURE=azure.infra1-standalone

./run.tests.sh
````

Or, pass the infrastrucure-id as an argument:

````bash
./run.tests.sh azure.infra1-standalone
````

- starts load
- monitors:
  - latency
  - vpn message rates
  - ping latency to broker
- stops load
- test results in: `test-results/stats/run.{run-id}`

## Run single legs of the tests
* [load](./load)
* [monitors](./monitor)

---
The End.
