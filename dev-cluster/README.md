## Dev Kubernetes Cluster (Vagrant + Libvirt + Kubespray)

This project provisions a 3-node Kubernetes cluster on your local machine using Vagrant (libvirt provider) and Kubespray.

### Prerequisites

- Linux host with KVM+Vagrant enabled
  - Verify: `egrep -c '(vmx|svm)' /proc/cpuinfo` should be > 0
  - Install/config guide: [infra-misc vagrant](https://github.com/milad-zanganeh/infra-misc/tree/master/vagrant)
- Packages:
  - `docker` to run the Kubespray container ([Install Docker Engine on Ubuntu](https://docs.docker.com/engine/install/ubuntu/))
  - `make`
- SSH key pair for Vagrant nodes:
  - Private: `~/.ssh/id_vagrant`
  - Public: `~/.ssh/id_vagrant.pub`
  - The public key is injected to VMs as their `authorized_keys` (see `conf/Vagrantfile`)

### Generate the required SSH key pair

Create the `id_vagrant` key pair in your `~/.ssh` directory:

```bash
ssh-keygen -t ed25519 -C "vagrant@dev-cluster" -f ~/.ssh/id_vagrant -N ""
```

Ensure permissions are correct (usually set by default):

```bash
chmod 600 ~/.ssh/id_vagrant
chmod 644 ~/.ssh/id_vagrant.pub
```

### Network and Storage Setup (one-time)

1) Create libvirt storage pool used by VMs:

```bash
bash scripts/pool.sh
```

2) Create libvirt network `vagrant-10-10.8` with subnet `10.10.8.0/24`:

```bash
bash scripts/net.sh
```

This will define a bridge `virbr-k8s` and DHCP range `10.10.8.100-200`. Nodes will use static IPs:

- dev-kubernetes-1: 10.10.8.11
- dev-kubernetes-2: 10.10.8.12
- dev-kubernetes-3: 10.10.8.13

### Bring Up the Cluster

From the repo root:

```bash
make kubernetes
```

This performs:

- `vagrant up` with provider `${PROVIDER:-libvirt}` to create 3 Debian 12 VMs (see `conf/Vagrantfile`)
- Runs Kubespray in a container to configure Kubernetes using the inventory in `inventory/k8s_cluster`

You can also run steps individually:

```bash
make nodes-up      # start VMs only
make kubespray     # run kubespray only
```

### Kubespray Details

- Kubespray is executed via `scripts/kubespray.sh`, which runs the image `quay.io/kubespray/kubespray:v2.28.0` with host networking and binds:
  - `inventory/k8s_cluster` → `/inventory`
  - `conf/ssh.conf` → `/root/.ssh/config.orig` (used for host aliasing)
  - `~/.ssh/id_vagrant` → `/root/.ssh/id_vagrant.orig` (private key for Ansible)
  - Credentials are generated under `/var/tmp/kube-certs` and mounted to `/inventory/k8s_cluster/credentials`
- Inside the container, `scripts/entrypoint.sh` runs:

```bash
ansible-playbook -i /inventory/k8s_cluster/inventory.ini cluster.yml
```

### Accessing the VMs

```bash
make nodes-status
make login                 # SSH into dev-kubernetes-1 (Password : vagrant)
make nodes-ssh-dev-kubernetes-2
```

### Customizing the Cluster

- Inventory: `inventory/k8s_cluster/inventory.ini`
- Global vars: `inventory/k8s_cluster/group_vars/all/*.yml`
- Cluster vars: `inventory/k8s_cluster/group_vars/k8s_cluster/*.yml`

Defaults include:

- Container runtime: `containerd`
- CNI: `calico` (`kube_network_plugin: calico`)
- API server LB port: `6443`

Adjust as needed before running `make kubernetes`.

Note: The cluster configuration files are copied from upstream Kubespray. You can modify them or completely replace them with a newer Kubespray release (Don't forget docker image version!); just make sure to update `inventory/k8s_cluster/inventory.ini` to match your nodes, IPs, and SSH settings.

### Tear Down / Lifecycle

```bash
make nodes-down      # stop VMs
make nodes-destroy   # destroy VMs
```

### Troubleshooting

- Ensure the libvirt network `vagrant-10-10.8` exists:

```bash
virsh net-list --all | grep vagrant-10-10.8 || bash scripts/net.sh
```

- Ensure the storage pool `vagrant_pool` exists and is active:

```bash
virsh pool-list --all | grep vagrant_pool || bash scripts/pool.sh
```

- Verify your `~/.ssh/id_vagrant(.pub)` exist and have proper permissions.

- If `vagrant up` fails due to provider issues, install `vagrant-libvirt` plugin:

```bash
vagrant plugin install vagrant-libvirt
```

### Notes

- Box: `generic/debian12`
- Each VM: 4 vCPU, 4GB RAM, 20GB disk (see `conf/Vagrantfile`)
- Host DNS inside VMs is set to Cloudflare (`1.1.1.1`) during provisioning.


