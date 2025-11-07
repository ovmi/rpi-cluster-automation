# Role: system_config

**Purpose:** Short description of what `system_config` does.

## Usage
```bash
ansible-playbook -i inventories/production playbooks/system_config.yml
```

## Variables (defaults)
See `roles/system_config/defaults/main.yml` (if present).

## Flow
```mermaid
flowchart TD
  A[Start] --> B[system_config tasks]
  B --> C[Done]
```
![system_config flow](../../media/system_config.png)
