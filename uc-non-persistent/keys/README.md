# SSH Keys

SSH Keys to access the VMs are stored in this directory.

_**Note: The keys must NOT be passphrase protected, i.e. they must have an empty passphrase.**_

If there are no preexisting SSH Keys, they can be created by running the following command:

### Azure

**_Note: `azure_key` is the default key name used in the scripts for Azure._**

**_Note: scripts are configured to look for {root}/keys/azure_key._**

````bash
cd {root}/uc-non-persistent/keys

ssh-keygen -t rsa -b 4096 -f azure_key

  > EMPTY PASSPHRASE! # otherwise terraform scripts will fail

````
### AWS
**_Note: `aws_key` is the default key name used in the scripts for AWS._**

**_Note: scripts are configured to look for {root}/keys/aws_key._**
````bash
cd {root}/uc-non-persistent/keys

ssh-keygen -t rsa -b 4096 -f aws_key

  > EMPTY PASSPHRASE! # otherwise terraform scripts will fail

````

---
The End.
