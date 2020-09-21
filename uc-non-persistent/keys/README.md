# SSH Keys

SSH Keys to access the VMs are stored in this directory.

_**Note: The keys must NOT be passphrase protected, i.e. they must have an empty passphrase.**_

If there are no preexisting SSH Keys, they can be created by running the following command:

````bash
cd {root}/uc-non-persistent/keys

ssh-keygen -t rsa -b 4096 -f azure_key

  > EMPTY PASSPHRASE! # otherwise terraform scripts will fail

# ensure the private key has the correct permissions
chmod 600 azure_key
````

## Notes

**_Note: `azure_key` is the default key name used in the scripts._**

**_Note: scripts are configured to look for {root}/keys/azure_key._**


---
The End.
