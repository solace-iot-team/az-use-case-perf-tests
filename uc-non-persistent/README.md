# Use Case: Non-persistent

[Overview: Market Data Distribution](./MDD.md).

### Structure

Follow the links to see installation & setup requirements.

- [Generate Keys](./keys)

- [Create Azure Resources: Terraform](./terraform)
  - generates output in `shared-setup`

- [Check Output](./shared-setup)

- [Configure VMs: Ansible & Ansible-Solace](./ansible)
  - reads `shared-setup` to generate the inventory file

- [Run Tests: Ansible](./ansible)

- [Check Results](./test-results)


---
The End.
