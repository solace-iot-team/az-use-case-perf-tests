# Tests

> :warning: **UNDER CONSTRUCTION**

## Concepts

1. Create 1 or multiple test specs

    Define the spec for running a series of tests.

    - test-specs/{test-spec-id}.test.spec.yml

2. Generate run specs

    Individual run specs are generated from the test spec.

    - script: _generate.run.specs.sh {test-spec-yml}
        - uses playbooks/generate.run.specs.playbook.yml
        - generates:
            - tmp/run-specs/{run-spec-id}.run.spec.yml
            - contains all the info for a single run

3. Run the run specs




---
The End.
