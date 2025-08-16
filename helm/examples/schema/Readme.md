# Schema Helm Chart

A simple example Helm chart for Kubernetes with schema validation.

This chart demonstrates Helm's schema validation feature using a `values.schema.json` file. Schema validation ensures that user-provided values conform to expected formats and constraints before deployment.

**Use cases:**
- Prevent deployment failures due to invalid configuration values
- Enforce naming conventions and formatting standards
- Validate data types and ranges (e.g., port numbers, replica counts)
- Ensure consistency across teams and environments

## Usage

Generate templates:

```bash
helm template my-release ./schema
```

## Schema Validation Example

This will cause a validation error due to invalid image tag format:

```bash
helm template my-release . --set image.tag=latest
``` 
