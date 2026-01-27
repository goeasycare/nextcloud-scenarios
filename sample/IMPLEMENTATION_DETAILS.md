# Nextcloud GitOps Minimum Working Example (MWE) - Implementation Plan

This document outlines the detailed plan to implement a GitOps-based CI/CD pipeline for Nextcloud using Argo CD, Argo Events, and Argo Workflows. All resources will be contained within the `sample/` directory.

## 1. Project Overview & Architecture

The goal is to create a self-contained "Minimum Working Example" (MWE) that demonstrates a full lifecycle:
1.  **Code Change**: A GitHub Release triggers the pipeline.
2.  **Event Ingestion**: **Argo Events** receives the webhook.
3.  **CI Pipeline**: **Argo Workflows** clones the repo, builds a container image using Kaniko, and pushes it to GitHub Container Registry (GHCR).
4.  **CD Sync**: **Argo CD** detects the changes (or is triggered) to sync the application stack (Nextcloud + Postgres + Redis) using the new image.

### Directory Structure
The `sample/` directory will be organized as follows:

```text
sample/
├── app/                  # The actual application manifests (Kustomize)
│   ├── kustomization.yaml
│   ├── nextcloud.yaml
│   ├── postgres.yaml
│   ├── redis.yaml
│   └── ...
├── argocd/               # Argo CD Application/ApplicationSet resources
│   └── applicationset.yaml
├── build/                # Build context (Dockerfile, scripts)
│   ├── Dockerfile
│   └── entrypoint.sh
├── events/               # Argo Events resources
│   ├── eventbus.yaml
│   ├── eventsource.yaml
│   └── sensor.yaml
├── workflow/             # Argo Workflows resources
│   └── build-push-workflow.yaml
└── secrets/              # Templates for required secrets (not committed)
    └── README.md
```

## 2. Prerequisites & Dependencies

Before applying the manifests, the following must be set up in the cluster:
*   **Kubernetes Cluster**
*   **Argo CD** installed (namespace: `argocd`)
*   **Argo Events** installed (namespace: `argocd`)
*   **Argo Workflows** installed (namespace: `argocd`)

### Required Secrets
Two critical secrets must be manually created in the `argocd` namespace. Usage of these will be documented in `sample/secrets/README.md`.

1.  **`github-access`**: Contains the Webhook secret string for validating GitHub events.
2.  **`docker-config-secret`**: Contains GitHub Personal Access Token (PAT) for pushing images to GHCR.

## 3. Resource Implementation Details

### A. Events (`sample/events/`)
*   **`eventbus.yaml`**: Native generic event bus.
*   **`eventsource.yaml`**: Configures the GitHub Webhook endpoint. 
    *   *Config*: Will contain `TODO` comments for `owner` and `repository`.
*   **`sensor.yaml`**: Listens for the event and triggers the Argo Workflow.

### B. Workflow (`sample/workflow/`)
*   **`build-push-workflow.yaml`**: A `WorkflowTemplate` or `Workflow` that:
    1.  Clones the repo.
    2.  Builds image with Kaniko (using context `sample/build/`).
    3.  Pushes to `ghcr.io/<owner>/<image>`.
    *   *Config*: Will contain `TODO` comments for destination image paths.

### C. Build Context (`sample/build/`)
*   **`Dockerfile`**: Custom Nextcloud image definition.
*   **`entrypoint.sh`**: Startup script if custom logic is needed.
*   **`php-optimization.ini`**: PHP config overrides.

### D. Application (`sample/app/`)
*   **Standard K8s Manifests**: Deployment, Service, Ingress, PVCs for Nextcloud, Postgres, and Redis.
*   **`kustomization.yaml`**: Glues them together.
    *   *Config*: Image name will be placeholder `ghcr.io/TODO_OWNER/TODO_CONTENT_IMAGE` to be updated by user.

### E. Argo CD (`sample/argocd/`)
*   **`applicationset.yaml`**: Automatically manages the Application deployment.
    *   *Config*: Repo URL will have a `TODO`.

## 4. Configuration Strategy
All project-specific values (URLs, Repo Owners, Secrets) will be marked with clear comments:
```yaml
# Replace with your GitHub Owner
owner: "goeasycare"
```
Or usually:
```yaml
value: "TODO_REPLACE_ME" # User must update this value
```

## 5. Execution Steps
1.  **Populate Secrets**: User runs commands to create K8s secrets.
2.  **Configure Files**: User finds all `TODO` items and replaces them.
3.  **Apply Events**: `kubectl apply -f sample/events/`
4.  **Apply Workflow**: `kubectl apply -f sample/workflow/`
5.  **Apply App/ArgoCD**: `kubectl apply -f sample/argocd/`
