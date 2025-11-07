# Role: cpu_temp_mon_kube

**Purpose:** Short description of what `cpu_temp_mon_kube` does.

## Usage
```bash
ansible-playbook -i inventories/production playbooks/cpu_temp_mon_kube.yml
```

## Variables (defaults)
See `roles/cpu_temp_mon_kube/defaults/main.yml` (if present).

## Flow
```mermaid
flowchart TD
  A[Start] --> B[cpu_temp_mon_kube tasks]
  B --> C[Done]
```
![cpu_temp_mon_kube flow](../../media/cpu_temp_mon_kube.png)
