# Terraform - Ansible Inventory & Playbook Templates

## Highlights

This folder and it's subfolders contain template files that will be used by terraform to create Ansible Inventory & Playbook Files.
Once terraform has rendered the template file, it will create a version on the Ansible folder, following the same folder structure.

## Customize SDKPerf Tests

If you want to modify any of the values of the SDKPerf ansibile playbook sample files, you can either modify or create copies of the files:

- start-sdkperf-c-pub.tpl 
- start-sdkperf-c-qcons.tpl

Inside the /terraform/templates/playbooks/ folder

> :warning: If you create copies of the files, make sure to include a Terraform "local_file" resource, to read the new template, parse it and generate the appropriate .yml file on the ansible path
