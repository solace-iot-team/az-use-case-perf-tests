# SSH Keys

SSH Keys to access the VMs are stored in this directory.

If there are no preexisting SSH Keys, they can be created by running the following command:

````bash
cd {root}/uc-non-persistent/keys
ssh-keygen -f azure_key
# ensure the private key has the correct permissions
chmod 600 azure_key
````

## Notes

**_Note: `azure_key` is the default key name used in the scripts._**

**_Note: scripts are configured to look for {root}/keys/azure_key._**


---
The End.
