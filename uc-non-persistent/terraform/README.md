# Infrastructure Deployment using Terraform

## Install Terraform

Install it.

## Prepare

* [Generate the keys](../keys)

````bash
# to enable terraform logging
export TF_LOG_PATH=./tf_log.log
export TF_LOG=TRACE # TRACE, DEBUG, INFO, WARN or ERROR
````

## Deployments

* [AWS - Standalone](./aws/standalone)
* [Azure - Standalone](./azure/standalone)

---
The End.
