## Helm hooks

This chart is a minimal example to demonstrate Helm hooks for learning. It deploys a simple `nginx` `Deployment`, a `Service`, and three `Job` hooks plus a `helm test` `Pod` that perform observable actions.

### What this chart demonstrates
- **pre-install / pre-upgrade hook**: Runs before a normal install/upgrade applies resources.
- **post-install hook**: Runs after a successful install.
- **pre-delete hook**: Runs before uninstall to allow cleanup.
- **helm test hook**: Runs when you execute `helm test` on the release.

The install/upgrade/delete hooks are `batch/v1 Job`s using an image configured at `.Values.hooks.image` (default `busybox:1.36`). The test hook is a `v1 Pod`. These resources just `echo` and briefly wait to make their execution visible. The test hook additionally curls the `Service` and verifies the nginx welcome page is returned.

### Files of interest
- `templates/deployment.yaml`: Sample `Deployment` using values from `values.yaml`.
- `templates/service.yaml`: ClusterIP `Service` exposing the app on port defined in `.Values.service.port`.
- `templates/hook-pre-install.yaml`: `pre-install,pre-upgrade` hook with weight `-1`, delete policy `before-hook-creation,hook-succeeded`.
- `templates/hook-post-install.yaml`: `post-install` hook with weight `1`, delete policy `hook-succeeded`.
- `templates/hook-pre-delete.yaml`: `pre-delete` hook with weight `0`, delete policy `hook-succeeded`.
- `templates/hook-test.yaml`: `helm test` hook Pod that curls the service and validates the nginx welcome page.

### Quick start
Install the chart with a release name (e.g., `demo`) into a namespace (e.g., `demo`):
```bash
helm install demo . -n demo --create-namespace
```

Expected resource names use the chart fullname helper: `<release>-hooks-<component>`, for example:
- `demo-hooks` (Deployment and Service)
- `demo-hooks-preinstall` (Job)
- `demo-hooks-postinstall` (Job)
- `demo-hooks-predelete` (Job)
- `demo-hooks-test` (Pod)

### Observe hook execution
Tip: For best visibility, open a second terminal to watch Pods/Jobs while you run Helm commands in the first.
In that second terminal you can watch in real-time:
```bash
kubectl get svc,deploy,pods -n demo -w
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

Run the chart tests:
```bash
helm test demo -n demo
kubectl logs pod/demo-hooks-test -n demo
```

Note: Jobs use `hook-succeeded` delete policies, so successful hook jobs are removed automatically. 


