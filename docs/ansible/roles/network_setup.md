# Role: network_setup

**Purpose:** Short description of what `network_setup` does.

## Usage
```bash
ansible-playbook -i inventories/production playbooks/network_setup.yml
```

## Variables (defaults)
See `roles/network_setup/defaults/main.yml` (if present).

## Flow
```mermaid
flowchart TD
  A[Start] --> B[network_setup tasks]
  B --> C[Done]
```
![network_setup flow](../../media/network_setup.png)
