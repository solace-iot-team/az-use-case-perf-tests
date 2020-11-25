# Shared Setup

Shared infrastructure and setup information.

Patterns:
- `{cloud-provider}.{infrastructure-id}.broker-nodes.json`
- `{cloud-provider}.{infrastructure-id}.sdkperf-nodes.json`
- `{cloud-provider}.{infrastructure-id}.env.json`
- `{cloud-provider}.{infrastructure-id}.inventory.json`
- - `{cloud-provider}.{infrastructure-id}.broker.manifest.json`
- with:
  - `{infrastrucure-id}`:
    - `{prefix}-{setup}`

For example:
````bash
azure.infra-1-standalone.broker-nodes.json
azure.infra-1-standalone.sdkperf-nodes.json
azure.infra-1-standalone.env.json
azure.infra-1-standalone.inventory.json
azure.infra-1-standalone.broker.manifest.json

````

---
The End.
