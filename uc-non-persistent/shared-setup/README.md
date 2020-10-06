# Shared Setup

Shared infrastructure and setup information.

Patterns:
- `{cloud-provider}.{infrastructure-id}.broker-nodes.json`
- `{cloud-provider}.{infrastructure-id}.sdkperf-nodes.json`
- with:
  - `{infrastrucure-id}`:
    - `{prefix}-{setup}`

For example:
````bash
azure.infra-1-standalone.broker-nodes.json
azure.infra-1-standalone.sdkperf-nodes.json

azure.infra-2-standalone.broker-nodes.json
azure.infra-2-standalone.sdkperf-nodes.json

aws.infra-1-standalone.broker-nodes.json
aws.infra-1-standalone.sdkperf-nodes.json
````

---
The End.
