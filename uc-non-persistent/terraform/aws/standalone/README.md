# Solace - Terraform & Ansible automated deployment - AWS Deployment

## Instructions

1. **Select the type of deployment you need: standalone or HA**  
   Terraform configuration files for AWS have been separated into 2 folders, according to the infrastructure you need to create:
   - [standalone brokers](./standalone)
   - [HA brokers](./HA)
   Select the one needed by getting into the respective folder.

2. **Edit aws-variables**  
   This file contains variables that will allow us to customize the instances that Terraform will provision on AWS.  
   Additional instructions are included in the file.

3. **Edit the /terraform/templates/playbooks/start-sdkperf-xx.tpl files**  
   These files contain the base SDKPerf tests that we'll run Manually via Ansible on our SDKPerf nodes, and will target our Solace Broker nodes.

   You can customize values like:
   - broker_port
   - broker_msg_vpn
   - client_username
   - client_password
   - client_connection_count
   - msg_payload_size_bytes
   - persistent

> :warning: Make sure the changes are aligned with the resources to be created by Terraform as well as the configurations to be applied by Ansible at bootstrap.

4. **Edit the /terraform/templates/playbooks/vars/testvpn-sol-brokers-vars.tpl file**  
   This file contains the Solace configurations to be created on the Solace brokers via SEMP triggered by Ansible at bootstrap.

   You can customize values like:
   - max_spool_usage
   - msg_vpn name
   - Client Profile
   - Client Username
   - Queues

> :information_source: Notice that this file has not been located under /ansible/playbooks/vars/, because although most of its contents are static, there is at the end of the file a dynamic block for Terraform to create a number of Solace queues, based on the number of SDKPerf nodes created.
> :warning: Make sure the changes are aligned with the resources to be created by Terraform as well as the configurations to be applied by Ansible at bootstrap.


5. **Configure Terraform to use the credentials of a sufficiently privileged IAM role**  
   You can do this a number of ways, but I recommend using environment variables as a quick, easy, and secure way of passing your keys to Terraform. Instructions [here](https://www.terraform.io/docs/providers/aws/index.html#environment-variables).
   ```
     export AWS_ACCESS_KEY_ID="anaccesskey"
     export AWS_SECRET_ACCESS_KEY="asecretkey"
   ```
