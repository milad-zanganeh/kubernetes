SHELL := /usr/bin/bash

export VAGRANT_CWD := $(CURDIR)
export VAGRANT_VAGRANTFILE := $(CURDIR)/conf/Vagrantfile
KUBESPRAY_SCRIPT := $(CURDIR)/scripts/kubespray.sh

PROVIDER ?= libvirt
FIRST_NODE ?= dev-kubernetes-1

.PHONY: help kubernetes kubespray nodes-up nodes-down nodes-destroy nodes-status nodes-ssh-% login

help:
	@echo "Targets:"
	@echo "  kubespray        - Run Kubespray"
	@echo "  kubernetes       - Bring up nodes and configure the cluster"
	@echo "  nodes-up         - Bring up nodes"
	@echo "  nodes-down       - Stop nodes"
	@echo "  nodes-destroy    - Destroy nodes"
	@echo "  nodes-status     - Show node status"
	@echo "  nodes-ssh-<node> - SSH into a node (e.g., make nodes-ssh-dev-kubernetes-1)"
	@echo "  login            - SSH into the first node ($(FIRST_NODE))"

kubernetes: nodes-up kubespray

nodes-up:
	vagrant up --provider $(PROVIDER)

kubespray:
	bash $(KUBESPRAY_SCRIPT)

nodes-down:
	vagrant halt

nodes-destroy:
	vagrant destroy -f

nodes-status:
	vagrant status

nodes-ssh-%:
	vagrant ssh $*

login:
	vagrant ssh $(FIRST_NODE)
