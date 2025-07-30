# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This repository contains the ArgoCD (GitOps) applications and Kubernetes manifests that define the HCM AI Playground platform. The platform provides hosted models via inference services, OpenShift AI for model refinement and RAGs, all in a managed environment.

## Architecture

The platform is structured around several key components:

### GitOps Applications (`gitops-applications/`)
ArgoCD applications that orchestrate the deployment of operators and workloads:
- `rhoai.application.yaml` - Red Hat OpenShift AI platform deployment
- `inference-service.application.yaml` - Model inference services (Mistral, LLama)
- `gpu-operator-certified.application.yaml` - NVIDIA GPU operator for GPU acceleration
- `advanced-cluster-management.application.yaml` - Multi-cluster management
- `serverless-operator.application.yaml` - Knative serverless platform
- `authorino-operator.application.yaml` - API authorization and authentication

### Operators (`operators/`)
Kustomize-based operator deployments adapted from the GitOps Catalog:
- `rhods-operator/` - Red Hat OpenShift Data Science platform with overlays for different versions (fast, eus-2.16, etc.)
- `gpu-operator-certified/` - NVIDIA GPU operator with AWS and OpenShift-specific configurations
- `advanced-cluster-management/` - Multi-cluster management across versions 2.8-2.13
- `serverless-operator/` - Knative serving and eventing
- `authorino-operator/` - Authorization service

### Inference Services (`inference-service/`)
Model serving configurations:
- `mistral-small/` - Mistral small model serving runtime
- `llama-scout/` - Llama model serving runtime
- Each service includes RBAC, service accounts, and inference service definitions

### Platform Services
- `llama-stack/` - Llama Stack deployment with Authorino authentication and Envoy proxy
- `grafana-dev/` - Development Grafana instance for monitoring
- `patch/argocd-permissions/` - RBAC permissions for ArgoCD service accounts

## Key Deployment Patterns

### Kustomize Structure
All components use Kustomize with a base/overlays pattern:
- `base/` - Core resource definitions
- `overlays/` - Environment-specific customizations
- `components/` - Optional feature additions

### Environment Overlays
Operators support multiple deployment channels:
- `fast/` - Latest development versions
- `stable/` - Production-ready versions
- `eus-X.Y/` - Extended Update Support versions
- Environment-specific configurations (e.g., `hcmaii01ue1/`, `rehoboam/`)

### GitOps Integration
All applications reference `https://github.com/app-sre/hcm-ai-playground` as the source repository with `main` branch as target revision.

## Important Configuration Notes

### GPU Configuration
- GPU operators are configured for OpenShift and AWS environments
- Time-slicing configurations available for GPU sharing (2-way, 4-way)
- MIG (Multi-Instance GPU) support for enterprise GPUs

### Authentication & Authorization
- Authorino provides API-level authorization
- Service mesh integration for secure communications
- OAuth client configurations for dashboard access

### Model Management
- Models are stored in S3-compatible storage
- The `scripts/upload-from-hf-to-s3-stream.py` utility transfers models from HuggingFace to S3
- Required environment variables: `MODELS_AWS_ACCESS_KEY_ID`, `MODELS_AWS_SECRET_ACCESS_KEY`, `MODELS_HF_TOKEN`, `MODELS_BUCKET_NAME`, `MODELS_PATH`

## Common Operations

### Deploying the Platform
1. Apply ArgoCD permissions: `oc apply -k patch/argocd-permissions/`
2. Deploy all applications: `oc apply -f gitops-applications/*.yaml`
3. Monitor deployments via ArgoCD UI

### Adding New Models
1. Create new directory under `inference-service/`
2. Include: `kustomization.yaml`, `inference-service.yaml`, `serving-runtime.yaml`, RBAC manifests
3. Update main `inference-service/kustomization.yaml` to include new model
4. Create corresponding ArgoCD application if needed

### Environment-Specific Deployments
Use Kustomize overlays to customize for specific environments:
- Reference appropriate overlay path in ArgoCD applications
- Environment configurations stored in `overlays/<environment>/`

### Model Upload Utility
Use the HuggingFace to S3 streaming script:
```bash
python scripts/upload-from-hf-to-s3-stream.py <repo_id>
```

## Repository Maintenance

### Adding Operators
1. Check [GitOps Catalog](https://github.com/redhat-cop/gitops-catalog/) for existing definitions
2. Create operator directory structure under `operators/`
3. Create corresponding ArgoCD application in `gitops-applications/`

### Updating Operator Versions
Modify the `patch-channel.yaml` files in overlay directories to change operator channels/versions.

### Security Considerations
- Secrets are managed via sealed-secrets or external secret management
- Service accounts follow principle of least privilege
- Network policies control inter-service communication