#!/bin/bash

# To change the owner of ssh files
cp /root/.ssh/config.orig /root/.ssh/config
cp /root/.ssh/id_vagrant.orig /root/.ssh/id_vagrant

ansible-playbook -i /inventory/k8s_cluster/inventory.ini cluster.yml