# Role: nvme_setup

**Purpose:** Short description of what `nvme_setup` does.

## Usage
```bash
ansible-playbook -i inventories/production playbooks/nvme_setup.yml
```

## Variables (defaults)
See `roles/nvme_setup/defaults/main.yml` (if present).

## Flow
```mermaid
flowchart TD
  A[Start] --> B[nvme_setup tasks]
  B --> C[Done]
```
![nvme_setup flow](../../media/nvme_setup.png)
