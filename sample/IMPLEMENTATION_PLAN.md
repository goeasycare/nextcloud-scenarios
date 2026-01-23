# Nextcloud CI/CD Pipeline Implementation Plan

This document outlines the implementation of a Minimum Working Example (MWE) for a complete CI/CD pipeline managed by GitHub and the Argo suite (Argo CD, Argo Workflows, Argo Events).

## Goal
To automate the lifecycle of a Nextcloud application:
1.  **Trigger**: specific GitHub Release.
2.  **Build**: Build container image from the release tag.
3.  **Publish**: Push image to GitHub Container Registry (GHCR).
4.  **Deploy**: Sync Argo CD ApplicationSet to deploy the new image.

## Architecture & Flow

1.  **GitHub Release Event** -> **Argo Events (EventSource)**
    *   Listens for webhooks from the GitHub repository.
2.  **Argo Events (Sensor)**
    *   Filters for "release" events.
    *   Triggers the **Argo Workflow**.
3.  **Argo Workflow**
    *   Clones the repository.
    *   Builds the Docker image using Kaniko or similar.
    *   Pushes the image to GHCR.
    *   (Optional) Commits a change to the git repo / updates the Argo CD app parameter to point to new tag (gitops pattern) OR uses `argocd app sync` command.
4.  **Argo CD**
    *   Detects the change (or is manually triggered) and syncs the Application to the Kubernetes cluster.

## Resources to Create (in `sample/`)

All resources will be namespaced (defaulting to `argocd` or a dedicated `ci-cd` namespace for the tools, and target namespace for the app).

### 1. Structure
```
sample/
├── events/
│   ├── eventbus.yaml       # NATS EventBus
│   ├── eventsource.yaml    # GitHub EventSource
│   └── sensor.yaml         # GitHub Sensor (Triggers Workflow)
├── workflow/
│   ├── workflow-rbac.yaml        # ServiceAccount & Roles for Workflow
│   └── build-push-workflow.yaml  # WorkflowTemplate for Build & Push
├── argocd/
│   └── applicationset.yaml # Argo CD ApplicationSet (Nextcloud Stack)
├── app/                    # Kustomize stack for Nextcloud + Redis + Postgres
│   ├── kustomization.yaml
│   ├── nextcloud.yaml
│   ├── redis.yaml
│   └── postgres.yaml
├── secrets/
│   └── patch-secrets.yaml  # Instructions/Placeholders for Secrets
└── README.md
```

### 2. Detailed Component Specs

#### A. Argo Events
*   **EventBus**: Required for Argo Events communication.
*   **EventSource**: configured type `github`.
    *   **TODO**: specific repo URL, secret token reference.
*   **Sensor**:
    *   Dependency: GitHub release event.
    *   Trigger: `k8s` resource (Workflow).
    *   **Parameters**: Pass the `tag_name` from the GitHub payload to the Workflow parameters.

#### B. Argo Workflows
*   **WorkflowTemplate**:
    *   **Inputs**: `git-revision` (tag).
    *   **Steps**:
        1.  **Clone**: Checkout the code at the tag.
        2.  **Build & Push**: Use Kaniko to build `Dockerfile` and push to `ghcr.io/<owner>/<repo>:<tag>`.
        3.  **Sync**: Trigger a refresh of the ApplicationSet or modify the `sample/app/kustomization.yaml` to pin the new image tag (GitOps approach), then let ArgoCD auto-sync. 

#### C. Argo CD
*   **ApplicationSet**:
    *   **Generator**: List generator (simulating a 'production' target).
    *   **Template**:
        *   Source: `sample/app` (Kustomize).
        *   Destination: Local cluster / configured target.
        *   **Resources**: Nextcloud, Redis, Postgres.

### 3. Prerequisites & Configuration (TODOs)

The user will need to configure:
1.  **GitHub Token**: For pulling code and pushing packages.
2.  **Webhook Secret**: For validating the GitHub webhook signature.
3.  **Registry Credentials**: Docker config for pushing to GHCR.

## Next Steps
1. Create `sample/events` resources.
2. Create `sample/workflow` resources.
3. Create `sample/argocd` resources.
4. Create `sample/app` (the Nextcloud deployment manifest).
