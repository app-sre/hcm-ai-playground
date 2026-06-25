# AGENTS.md

## Project Overview

HCM AI Playground is a GitOps configuration repository that declaratively defines the HCM AI
Playground platform. It contains ArgoCD Application CRDs, Kubernetes manifests, and Kustomize
payloads that, when applied to an OpenShift cluster, install the operators, configuration, and
workloads for hosted model inference, OpenShift AI, and supporting platform services. Operated by
Red Hat's HCM organization.

## Dependencies

- **Runtime:** OpenShift cluster with GPU-accelerated nodes, ArgoCD or OpenShift GitOps Operator
- **CLI tools:** `oc` (OpenShift CLI), `kustomize` (bundled with `oc`). Jsonnet files in
  `llama-stack/base/` and `grafana-dev/base/` are committed as source; a `jsonnet` CLI is needed
  only if modifying those files.
- **Dependency updates:** Renovate Bot monitors container image versions in Kustomize files via
  `renovate.json`

## Development Commands

There is no build system, test suite, or linter configured in this repository. All changes are
validated through ArgoCD reconciliation on the target cluster.

```sh
# Deploy RBAC permissions
oc apply -k patch/argocd-permissions/

# Deploy all GitOps applications
oc apply -f gitops-applications/*.yaml

# Upload a model from HuggingFace to S3
python scripts/upload-from-hf-to-s3-stream.py <repo_id>
```

There is no CI pipeline in this repository. Deployment is handled entirely by ArgoCD with
`syncPolicy.automated.selfHeal: true` on all applications. Renovate Bot opens PRs for container
image version updates.

## Architecture

The repository contains no application source code. It is a pure Infrastructure-as-Code repository
using Kustomize base/overlay patterns for all resource definitions.

### Directory Structure

- `gitops-applications/` — 15 ArgoCD `Application` CRDs pointing to `main` branch of
  `app-sre/hcm-ai-playground`. Each application targets a specific component (operators, inference
  services, platform services).
- `operators/` — OLM operator subscriptions adapted from the GitOps Catalog. Each operator uses
  `base/overlays/` with channel-specific overlays (`fast/`, `stable/`, `eus-X.Y/`) and
  environment-specific overlays (e.g., `hcmaii01ue1/`, `rehoboam/`).
- `inference-service/` — Model serving configurations for vLLM-based inference (Mistral, Mistral
  Small, Llama Scout, Qwen3-32B). Each model directory includes `kustomization.yaml`,
  `inference-service.yaml`, `serving-runtime.yaml`, and RBAC manifests.
- `llama-stack/` — Llama Stack deployment with Envoy proxy and Authorino authentication. Uses
  Jsonnet for templated route and deployment generation.
- `agent-swarm/` — Agent swarm workload with base and environment overlays.
- `dashboards/` — Grafana dashboard ConfigMaps for monitoring.
- `grafana-dev/` — Development Grafana instance manifests (Jsonnet-templated).
- `openshell/` — OpenShell and agent-sandbox configurations.
- `prometheusrules/` — PrometheusRule CRDs for vLLM monitoring.
- `qdrant/` — Qdrant vector database deployment.
- `patch/` — ArgoCD RBAC permission patches (ClusterRoles and ClusterRoleBindings).
- `scripts/` — Utility script for streaming model uploads from HuggingFace to S3.

### Key Patterns

- **Kustomize base/overlays:** All components follow `base/` for core definitions and `overlays/`
  for environment or version-specific customization.
- **ArgoCD self-healing:** All applications use `syncPolicy.automated.selfHeal: true`, meaning
  drift from the declared state is automatically corrected.
- **Operator channel management:** Operator versions are controlled via `patch-channel.yaml` in
  overlay directories, not by editing base subscriptions.

## Code Style

There are no linters, formatters, or code style enforcement tools configured in this repository.
YAML manifests follow standard Kubernetes resource conventions. Jsonnet files in `llama-stack/base/`
and `grafana-dev/base/` follow standard Jsonnet formatting.

## Common Mistakes

1. **Editing base files instead of creating overlays.** Environment-specific changes should use
   Kustomize overlays, not direct edits to `base/` resources. Direct edits to base files affect all
   environments simultaneously.

2. **Forgetting to create a corresponding ArgoCD Application.** Adding a new operator or workload
   directory without creating a matching ArgoCD Application in `gitops-applications/` means the
   resources will not be deployed. Every deployable component needs both a Kustomize payload and an
   ArgoCD Application CRD.

3. **Changing operator versions in the wrong file.** Operator channel/version changes belong in
   `patch-channel.yaml` files within overlay directories, not in the base `Subscription` resource.
   Editing the base subscription will be overwritten by overlays.

4. **Missing namespace labels for ArgoCD.** New namespaces must be labeled with
   `argocd.argoproj.io/managed-by=<argocd-namespace>` or ArgoCD will not manage resources in them.
   This is easy to forget when adding a new component that targets a new namespace.

5. **Assuming secrets are stored in-repo.** Secrets are managed via sealed-secrets or external
   secret management, not stored as plain Kubernetes `Secret` resources in this repository. Do not
   add unencrypted secrets to any manifest.

## Deployment

All deployment is handled by ArgoCD. Apply the GitOps Application CRDs to the target cluster and
ArgoCD reconciles the desired state automatically. See the [deployment instructions in the
README][readme-deploy] for the full setup sequence.

[readme-deploy]: ./README.md#building-your-own-ai-playground
