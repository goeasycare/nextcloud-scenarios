# Nextcloud GitOps Sample

This folder contains a complete reference implementation for a Nextcloud CI/CD pipeline using Argo CD, Argo Events, and Argo Workflows.

## Architecture

*   **Trigger**: GitHub Release (webhook).
*   **Pipeline**: Argo Events triggers an Argo Workflow.
*   **Build**: Argo Workflow builds a container image containing Nextcloud and pushes it to GHCR.
*   **Deployment**: Argo CD **ApplicationSet** manages the deployment of the full stack (Nextcloud, Redis, Postgres) across environments.

## Directory Structure

*   `app/`: The Kustomize manifests for the application stack (Nextcloud + Redis + Postgres).
*   `argocd/`: Contains the **ApplicationSet** definition to deploy the `app/` manifests.
*   `events/`: Configuration for connecting GitHub Webhooks to the K8s cluster.
*   `secrets/`: Documentation on required secrets (GitHub tokens, Docker config).
*   `workflow/`: The CI pipeline definition (Build & Push).
*   `build/`: The Dockerfile and supporting scripts for building the custom Nextcloud image.

## Quick Start

1.  **Secrets**: Follow the instructions in [secrets/README.md](secrets/README.md) to create the necessary kubernetes secrets.
2.  **Configuration**: Search for all `TODO` comments in the YAML files and replace them with your repository details (Owner, Repo Name, URLs).
    *   `events/eventsource.yaml`
    *   `workflow/build-push-workflow.yaml`
    *   `argocd/applicationset.yaml`
    *   `app/kustomization.yaml`
    *   `app/nextcloud.yaml`
3.  **Apply**:
    ```bash
    # Apply Events Infrastructure
    kubectl apply -f events/

    # Apply Workflow Infrastructure
    kubectl apply -f workflow/

    # Apply ArgoCD ApplicationSet
    kubectl apply -f argocd/
    ```
4.  **Trigger**: Create a new Release in your GitHub repository to start the pipeline.

## Implementation Details

For a deep dive into the architecture and logical flow, see [IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md).
