# Role: {{ role_name }}

Short description
: A brief one-line summary of what this role does.

Prerequisites
: - Any OS or package requirements

Role variables
: - `{{ role_name }}_var1` — what it controls (default in `defaults/main.yml`)

Example usage
```yaml
- hosts: all
  roles:
    - role: {{ role_name }}
      vars:
        {{ role_name }}_var1: value
```

Files
 - `defaults/main.yml` — default variables
 - `tasks/main.yml` — main tasks
 - `handlers/main.yml` — handlers (if present)

Notes
- Add any important warnings, idempotency notes, or compatibility tips here.

License
- See repository `LICENSE` or `README.md`.
