#!/usr/bin/env bash

NET_NAME="${1:-vagrant-10-10.8}"
SUBNET="10.10.8.0/24"
BRIDGE="virbr-k8s"
GATEWAY="10.10.8.1"
DHCP_START="10.10.8.100"
DHCP_END="10.10.8.200"

TMPXML="$(mktemp)"
cat >"$TMPXML" <<EOF
<network>
  <name>$NET_NAME</name>
  <bridge name='$BRIDGE' stp='on' delay='0'/>
  <ip address='${GATEWAY}' netmask='255.255.255.0'>
    <dhcp>
      <range start='${DHCP_START}' end='${DHCP_END}'/>
    </dhcp>
  </ip>
</network>
EOF

if virsh net-info "$NET_NAME" &>/dev/null; then
  echo "Network '$NET_NAME' already exists."
else
  virsh net-define "$TMPXML"
  virsh net-start "$NET_NAME"
  virsh net-autostart "$NET_NAME"
  echo "Created and started network '$NET_NAME' on $BRIDGE ($SUBNET)."
fi
rm -f "$TMPXML"