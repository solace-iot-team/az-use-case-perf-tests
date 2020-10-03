# SSH Keys

SSH Keys to access the VMs are stored in this directory.

_**Note: The keys must NOT be passphrase protected, i.e. they must have an empty passphrase.**_

If there are no preexisting SSH Keys, they can be created by running the following command:

### Azure 
````bash
cd {root}/uc-non-persistent/keys

ssh-keygen -t rsa -b 4096 -f az_key

  > EMPTY PASSPHRASE! # otherwise terraform scripts will fail

# ensure the private key has the correct permissions
chmod 600 az_key
````
### AWS 
````bash
cd {root}/uc-non-persistent/keys

ssh-keygen -t rsa -b 4096 -f aws_key

  > EMPTY PASSPHRASE! # otherwise terraform scripts will fail

# ensure the private key has the correct permissions
chmod 600 aws_key
````
## Notes

**_Note: `az_key` is the default key name used in the scripts for Azure._**
**_Note: `aws_key` is the default key name used in the scripts for AWS._**

**_Note: scripts are configured to look for {root}/keys/az_key._**
**_Note: scripts are configured to look for {root}/keys/aws_key._**

---
The End.
