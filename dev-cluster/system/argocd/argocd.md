# Argo CD

## Kubespray vs Helm

Kubespray can deploy Argo CD by enabling it in the cluster addons file (`inventory/.../group_vars/k8s_cluster/addons.yml`): set `argocd_enabled: true` (and optionally `argocd_namespace`, `argocd_admin_password`, etc.). That path is integrated with the rest of the Kubespray playbook.

The steps below use the official Helm chart instead, on purpose: they show how the pieces fit together (namespace, ingress, TLS, resources, insecure server behind the ingress) and are useful when you want to experiment or compare with the Kubespray addon.

## Helm install (learning setup)

You need the Argo Helm repo (`helm repo add argo https://argoproj.github.io/argo-helm` and `helm repo update`) if `argo/argo-cd` is not already available locally.

Install into the `argocd` namespace (create it first if needed: `kubectl create namespace argocd`):

```bash
helm install argocd argo/argo-cd -n argocd --values values.yaml
```

Example `values.yaml` (Traefik ingress, TLS on `websecure`, resource limits for server / repo-server / controller):

```yaml
server:
  ingress:
    enabled: true
    ingressClassName: traefik
    hostname: argocd.miladzanganeh.com
    paths:
      - /
    pathType: Prefix
    annotations:
      traefik.ingress.kubernetes.io/router.entrypoints: websecure
    tls: true
  resources:
    limits:
      cpu: 4
      memory: 2G
    requests:
      cpu: 250m
      memory: 256Mi

configs:
  params:
    server.insecure: true

repoServer:
  resources:
    limits:
      cpu: 4
      memory: 2G
    requests:
      cpu: 250m
      memory: 256Mi

controller:
  resources:
    limits:
      cpu: 4
      memory: 2G
    requests:
      cpu: 250m
      memory: 256Mi
```

`server.insecure: true` is common when TLS terminates at the ingress; the UI is still served over HTTPS to browsers via Traefik.

## Initial admin password

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
echo
```

(You can also use `argocd admin initial-password -n argocd` if the Argo CD CLI is installed.)
