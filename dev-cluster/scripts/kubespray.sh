#!/bin/bash
SCRIPT_DIR="$(dirname "$0")"
CREDENTIALS_DIR="/var/tmp/kube-certs"
SSH_PRIVATE_KEY_PATH="${HOME}/.ssh/id_vagrant"
SSH_PUBLIC_KEY_PATH="${HOME}/.ssh/id_vagrant.pub"
mkdir -p "$CREDENTIALS_DIR"

source "$SCRIPT_DIR/.env"
docker run --rm -it \
  --mount type=bind,source="$SCRIPT_DIR"/../inventory,dst=/inventory \
  --mount type=bind,source="$CREDENTIALS_DIR",dst=/inventory/k8s_cluster/credentials \
  --mount type=bind,source="$SCRIPT_DIR"/../conf/ssh.conf,dst=/root/.ssh/config.orig \
  --mount type=bind,source="$SSH_PRIVATE_KEY_PATH",dst=/root/.ssh/id_vagrant.orig,readonly \
  --network host \
  --mount type=bind,source="${SCRIPT_DIR}"/../scripts/,dst=/scripts \
  quay.io/kubespray/kubespray:v2.28.0 /scripts/entrypoint.sh


