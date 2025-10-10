
INVENTORY=inventories/production/hosts
PLAYBOOK=roles/k3s_install/tasks/main.yml

.PHONY: run lint ping

run:
	ansible-playbook $(PLAYBOOK) -i $(INVENTORY)

lint:
	ansible-lint $(PLAYBOOK)

ping:
	ansible all -i $(INVENTORY) -m ping
