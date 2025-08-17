## Helm hooks

This chart is a minimal example to demonstrate Helm hooks for learning. It deploys a simple `nginx` `Deployment` and three `Job` hooks that print messages and sleep briefly so you can observe their behavior.

### What this chart demonstrates
- **pre-install / pre-upgrade hook**: Runs before a normal install/upgrade applies resources.
- **post-install hook**: Runs after a successful install.
- **pre-delete hook**: Runs before uninstall to allow cleanup.

Each hook is a `batch/v1 Job` using an image configured at `.Values.hooks.image` (default `busybox:1.36`). The jobs just `echo` and `sleep 10` to make their execution visible.

### Files of interest
- `templates/hook-pre-install.yaml`: `pre-install,pre-upgrade` hook with weight `-1`, delete policy `before-hook-creation,hook-succeeded`.
- `templates/hook-post-install.yaml`: `post-install` hook with weight `1`, delete policy `hook-succeeded`.
- `templates/hook-pre-delete.yaml`: `pre-delete` hook with weight `0`, delete policy `hook-succeeded`.
- `templates/deployment.yaml`: Sample `Deployment` using values from `values.yaml`.

### Quick start
Install the chart with a release name (e.g., `demo`) into a namespace (e.g., `demo`):
```bash
helm install demo . -n demo --create-namespace
```

Expected hook `Job` names use the chart fullname helper: `<release>-hooks-<hook>`, for example:
- `demo-hooks-preinstall`
- `demo-hooks-postinstall`
- `demo-hooks-predelete`

### Observe hook execution
Tip: For best visibility, open a second terminal to watch Pods/Jobs while you run Helm commands in the first.
In that second terminal you can watch in real-time:
```bash
kubectl get pods -n demo -w
kubectl get jobs -n demo -w
```
List jobs created by hooks:
```bash
kubectl get jobs -n demo -l app.kubernetes.io/instance=demo
```

View logs (while the job is running):
```bash
kubectl logs job/demo-hooks-preinstall -n demo
kubectl logs job/demo-hooks-postinstall -n demo
```

Trigger the `pre-delete` hook by uninstalling the release, then quickly check the job:
```bash
helm uninstall demo -n demo
kubectl get jobs -n demo -l app.kubernetes.io/instance=demo
kubectl logs job/demo-hooks-predelete -n demo
```

Note: Jobs use `hook-succeeded` delete policies, so successful hook jobs are removed automatically. 

