# Infrastructure : Standalone : Auto-Run

Exmaples for standup and destroy of a set of infrastructures.

## Infrastructure Specs

These are variables for the respective terraform variable templates.

_Note: they are different depending on the cloud provider._

Pattern:

`{cloud-provider-id}.{infrastructure-config-id}.tfvars.json`

where:
  * {cloud-provider-id}: ['azure' | 'aws']
  * {infrastructure-config-id}: custom tag/prefix.
    - **_Note: the config-id is again specified inside the variables files and re-used in the test specs._**

Examples:

- `aws.1-auto.tfvars.json`
- `azure.1-auto.tfvars.json`

## Scripts

Copy and modify these scripts to customize the infrastructures that are managed.

**run.apply.sh**, **run.destroy.sh**

````bash

./run.apply.sh
tail -f logs/run.apply.sh.out

./run.destroy.sh
tail -f logs/run.destroy.sh.out

````

### Output: Successful Run

````bash
cat logs/run.apply.out
cat logs/run.destroy.out

FINISHED:SUCCESS
````

````bash

ls logs/**.SUCCESS.out

````

## Output: Failed Run

````bash
cat logs/run.apply.sh.out
cat logs/run.destroy.sh.out

FINISHED:FAILED

````

Error Details:
````bash
cat logs/**.ERRROR.out

<list of error lines in log files>

````

---
The End.
