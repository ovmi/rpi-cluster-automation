
INVENTORY=inventories/production/hosts
PLAYBOOK=roles/k3s_install/tasks/main.yml

.PHONY: run lint ping

run:
	ansible-playbook $(PLAYBOOK) -i $(INVENTORY)

lint:
	ansible-lint $(PLAYBOOK)

ping:
	ansible all -i $(INVENTORY) -m ping


.PHONY: diagrams
diagrams:
	mkdir -p docs/media
	find docs -name "*.mmd" -exec sh -c 'for f; do mmdc -i "$$f" -o "docs/media/$$(basename "$$f" .mmd).png"; done' sh {} +
