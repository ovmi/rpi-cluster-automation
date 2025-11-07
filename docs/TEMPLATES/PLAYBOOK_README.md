# Playbook: {{ playbook_name }}

Description
: Short description of what the playbook does.

Usage
```bash
ansible-playbook -i inventories/production/hosts playbooks/{{ playbook_file }}
```

Recommended variables
 - `example_var` — explanation (set in `inventories/` or via `-e`)

Notes
 - Any special privileges, reboot behavior, or expected host groups.

See also
 - roles/ — roles used by this playbook.
