# HCM AI Playground Platform Definition and GitOps

## Introduction

This repository contains the ArgoCD (GitOps) applications that, when applied to a cluster, will
install the operators, configuration, and workload to create or replicate the HCM AI Playground.

The HCM AI Playground is a space for Software Engineers to leverage hosted models via an Inference
Service, refine their own models and RAGs via OpenShift AI, or leverage the entire OpenShift AI
platform in a managed environment.

You can use this repository to configure most or all replicas of the HCM AI Playground environment
operated by Red Hat's HCM organization _or_ you can fork and use this repository to stand up your
own environment analogous to the HCM AI Playground environment.

## Prerequisites

- An OpenShift cluster with at least one GPU-accelerated node (NVIDIA by default; AMD GPUs require
  installing AMD's GPU Operator instead)
- The [OpenShift GitOps Operator][openshift-gitops] installed on the cluster (or
  [ArgoCD][argocd-getting-started] if preferred)
- `oc` CLI configured with cluster access

## Using this Repository

### Repository Structure

The repository is structured as follows:

- `gitops-applications/` — ArgoCD Application CRDs that, when applied to a cluster, install the
  operators, configuration, and workload defined in the other portions of this repository
- `inference-service/` — workload and configuration that defines the inference-as-a-service
  component of the AI Playground
- `operators/` — Kustomize payloads pulled or adapted from the [GitOps Catalog][gitops-catalog] to
  install the operators necessary for the AI Playground
- `patch/` — patches that must be applied before the remainder of the gitops-applications defined
  in this repository
- `scripts/` — useful companion scripts for use alongside the completed platform
- `agent-swarm/` — agent swarm workload (base and overlays)
- `dashboards/` — Grafana dashboard ConfigMaps
- `llama-stack/` — Llama Stack, Envoy proxy, and Authorino auth configurations
- `openshell/` — OpenShell and agent-sandbox configurations
- `prometheusrules/` — PrometheusRule CRDs for vLLM monitoring
- `qdrant/` — Qdrant vector database deployment

### Building Your Own AI Playground

To stand up a new replica of the AI Playground based on this repository:

1. Provision an OpenShift cluster with at least one GPU-accelerated node
2. Install the [OpenShift GitOps Operator][openshift-gitops] on your cluster (or
   [ArgoCD][argocd-getting-started] if you prefer)
   1. Enable OpenShift GitOps or ArgoCD in cluster-wide mode because the applications reside in
      multiple namespaces. OpenShift GitOps automatically deploys in cluster-wide mode if deployed
      in the `openshift-gitops` (default) namespace
   2. Modify your ArgoCD Custom Resource configuration to enable ArgoCD to reconcile Applications
      from all namespaces:
      1. Edit the ArgoCD instance and add the following to both `spec.server` and
         `spec.controller`:

         ```yaml
         extraCommandArgs:
           - '--application-namespaces=*'
         ```

      2. Edit the Default AppProject CR to include the following in its `spec`:

         ```yaml
         sourceNamespaces:
           - '*'
         ```

   3. For every namespace that you want ArgoCD to work in, apply a label:

      ```sh
      oc label namespace <namespace-name> argocd.argoproj.io/managed-by=<namespace-of-the-argocd-instance>
      ```

3. Apply the ClusterRoles and ClusterRoleBindings in `patch/argocd-permissions` to give the ArgoCD
   ServiceAccount the necessary permissions:

   ```sh
   oc apply -f patch/argocd-permissions/
   ```

4. Apply the GitOps applications to install all operators and workload:

   ```sh
   oc apply -f gitops-applications/*.yaml
   ```

5. Navigate to the ArgoCD UI on your cluster and verify that the Applications reconcile correctly

### Modifying an Existing AI Playground Environment

If you would like to modify an existing deployment that references this repository, edit any file in
the operator or workload directories (excludes `gitops-applications/`, `patch/`, and `scripts/`).
That change will be reconciled to environments by ArgoCD shortly.

If a modification should only be made to one environment, create a Kustomize overlay for that
environment's configuration to overlay the current base files and reference that specific
environment's config in the environment's version of the gitops-application.

## Developing and Extending the AI Playground

### Adding Operators

Start by checking for an existing entry in the [GitOps Catalog][gitops-catalog]. If there is an
entry, copy it into the `operators/` directory. If there is not, use the existing operators as a
model and create a new directory and Kustomize definition for the operator in `operators/`.

Once you have added a new folder, create a corresponding ArgoCD Application in
`gitops-applications/`, using an existing file as an example.

### Adding Workload

Create a new folder and GitOps Application if the workload is net-new, or add it to an existing
directory if the workload extends an existing workload.

For example, to add a model to the current Inference Service, add its definition to the payload in
the `inference-service/` directory.

To add a net-new service (e.g., model validation for content or correctness), add a new directory
with its own Kustomize definition, then create a corresponding GitOps Application in
`gitops-applications/` and apply it to the target cluster.

## Contributing

See the [contributing guidelines][contributing] for details on how to contribute to this project.

## License

TODO: no LICENSE file found in this repository — please add one.

[openshift-gitops]: https://docs.redhat.com/en/documentation/red_hat_openshift_gitops/1.16/html/installing_gitops/installing-openshift-gitops
[argocd-getting-started]: https://argo-cd.readthedocs.io/en/stable/getting_started/
[gitops-catalog]: https://github.com/redhat-cop/gitops-catalog/
[contributing]: ./CONTRIBUTING.md
