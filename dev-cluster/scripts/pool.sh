#!/bin/bash

POOL_NAME="vagrant_pool"

sudo mkdir -p /var/lib/libvirt/images/$POOL_NAME
sudo virsh pool-define-as $POOL_NAME dir --target /var/lib/libvirt/images/$POOL_NAME
sudo virsh pool-build $POOL_NAME
sudo virsh pool-start $POOL_NAME
sudo virsh pool-autostart $POOL_NAME

virsh pool-list --all 