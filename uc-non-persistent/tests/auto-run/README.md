# Tests : Auto-Run

Exmaples for running tests.

## Test Specs

### Template:
  * `template.{spec-id}.test.spec.yml`

### Examples:
  * `1_auto.test.spec.yml`
  * `2_auto.test.spec.yml`

### Create a new Test Spec:

````bash
cp template.{spec-id}.test.spec.yml {new-spec-id}.test.spec.yml

vi {new-spec-id}.test.spec.yml

# customize the test spec

````

## Run Test Spec

````bash

./run.sh
tail -f logs/run.sh.out

````

### Output: Successful Run

````bash
cat logs/run.sh.out

FINISHED:SUCCESS
````

````bash

ls logs/**.SUCCESS.out

````

### Output: Failed Run

````bash
cat logs/run.sh.out

FINISHED:FAILED

````

Error Details:
````bash
cat logs/**.ERRROR.out

<list of error lines in log files>

````

## Abort a Test Run

````bash

./abort.sh
tail -f logs/abort.sh.out

````


---
The End.
