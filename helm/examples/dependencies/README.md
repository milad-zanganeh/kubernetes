# Helm Chart Dependencies Example

This example demonstrates how to use Helm chart dependencies with library charts in Kubernetes. It shows how to create reusable components using library charts that can be shared across multiple application charts.

## Overview

This example consists of two charts:

- **`mylib/`** - A library chart that provides reusable templates and helper functions
- **`myservice/`** - An application chart that depends on the library chart

## Structure

```
dependencies/
├── mylib/                    # Library chart
│   ├── Chart.yaml           # Library chart metadata (type: library)
│   ├── values.yaml          # Default values for the library
│   └── templates/
│       ├── _helper.tpl      # Helper template functions
│       └── _deployment.yaml # Reusable deployment template
└── myservice/               # Application chart
    ├── Chart.yaml           # Application chart with dependency on mylib
    ├── values.yaml          # Values specific to this service
    └── templates/
        └── deployment.yaml  # Uses the library deployment template
```

## Library Chart (`mylib`)

The library chart provides:

### Helper Functions
- `mylib.name` - Returns the base name of the chart
- `mylib.fullname` - Returns a fully qualified name for resources
- `mylib.labels` - Provides common Kubernetes app labels

### Reusable Templates
- `mylib.deployment` - A complete deployment template with:
  - Configurable replica count
  - Container image and port settings
  - Health checks (readiness and liveness probes)
  - Resource limits and requests

## Application Chart (`myservice`)

The application chart demonstrates:
- How to declare a dependency on a local library chart
- How to use library templates in your own templates
- How to configure the service through values

### Configuration

The `myservice` chart can be configured through `values.yaml`:

```yaml
image:
  repository: myregistry/orders-service
  tag: v2.3.1

replicaCount: 3
containerPort: 8081

resources:
  limits:
    cpu: "500m"
    memory: "512Mi"
  requests:
    cpu: "250m"
    memory: "256Mi"
```

## Usage

### 1. Update Dependencies

Before using the application chart, update its dependencies:

```bash
cd myservice
helm dependency update
```

This will download and package the `mylib` dependency.

### 2. Render the Templates

Test the chart by rendering its templates:

```bash
helm template test-release ./myservice
```

## Further Reading

- [Helm Chart Dependencies](https://helm.sh/docs/helm/helm_dependency/)
- [Library Charts](https://helm.sh/docs/topics/library_charts/)
- [Template Function Reference](https://helm.sh/docs/chart_template_guide/function_list/) 