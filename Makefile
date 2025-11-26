.PHONY: help play play-verbose play-check clean

help:
	@echo "Ansible Playbook Commands"
	@echo "═══════════════════════════════════════"
	@echo "  make play PLAYBOOK=path/to/playbook.yml    - Run specified playbook"
	@echo "  make play-v PLAYBOOK=path/to/playbook.yml  - Run with verbose output"
	@echo "  make play-check PLAYBOOK=path/to/playbook.yml - Run in check mode (dry-run)"
	@echo "  make play-all                              - Run all integrations (use with caution)"
	@echo "  make play-all-v                            - Run all integrations with verbose output"
	@echo "  make clean        - Clean dev_collection symlink"
	@echo "  make help         - Show this help message"

play:
	@if [ -z "$(PLAYBOOK)" ]; then echo "Error: Please specify PLAYBOOK variable, e.g., make play PLAYBOOK=playbooks/integrations/some.yml"; exit 1; fi
	@./run-playbook.sh "$(PLAYBOOK)"

play-v:
	@if [ -z "$(PLAYBOOK)" ]; then echo "Error: Please specify PLAYBOOK variable, e.g., make play-v PLAYBOOK=playbooks/integrations/some.yml"; exit 1; fi
	@./run-playbook.sh -vv "$(PLAYBOOK)"

play-check:
	@if [ -z "$(PLAYBOOK)" ]; then echo "Error: Please specify PLAYBOOK variable, e.g., make play-check PLAYBOOK=playbooks/integrations/some.yml"; exit 1; fi
	@./run-playbook.sh --dry-run "$(PLAYBOOK)"

play-all:
	@./run-playbook.sh playbooks/upgrade_all_integrations.yml

play-all-v:
	@./run-playbook.sh -vv playbooks/upgrade_all_integrations.yml

clean:
	@rm -rf dev_collection
	@echo "✓ Cleaned dev_collection"

.DEFAULT_GOAL := help
