# OpenShell CLI Container Image

Simple container image with the OpenShell CLI installed.

## Build

```bash
docker build -t openshell-cli:latest .
```

## Push to registry

```bash
# Tag for your registry
docker tag openshell-cli:latest quay.io/your-org/openshell-cli:latest

# Push
docker push quay.io/your-org/openshell-cli:latest
```

## Usage

```bash
# Run CLI
docker run --rm openshell-cli:latest --help

# Use in Kubernetes Job
kubectl run openshell-cli --image=quay.io/your-org/openshell-cli:latest --rm -it -- gateway list
```
