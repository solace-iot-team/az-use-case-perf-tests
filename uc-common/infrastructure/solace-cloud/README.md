# Solace Cloud

> :warning: **DEFUNCT**
> may be updated in a later cycle.


Manage Solace Cloud service for use cases.

## Configure

````bash
cd inventory
cp template.inventory.sc-accounts.yml inventory.sc-accounts.yml
vi inventory.sc-accounts.yml
  # enter values / adjust to your solace cloud account
cd ..
````

````bash
cd vars
vi vars.sc-service.yml
  # adjust to your needs if required
cd ..
````

## Run

````bash
./run.create.sh
````
- Creates the service in Solace Cloud
- Retrieves Connection Details
- Copies them to use case specific shared-setup directory.
  - for example: `uc-non-persistent/shared-setup`

## Delete

````bash
./run.delete.sh
````

---
The End.
