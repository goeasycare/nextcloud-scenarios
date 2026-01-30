# Nextcloud GitOps Hybrid Pipeline - Architecture Documentation

This document describes the implementation of the Hybrid GitOps/App-of-Apps pipeline for Nextcloud using Argo CD, Argo Events, and Argo Workflows.

## 1. Architecture Overview 

This implementation uses a **Hybrid Event Strategy** to separate "Deployment Syncing" from "Application Building."

### The "Ear" (EventSource)
A single **EventSource** (`github-event-source`) listening on two distinct channels:
1.  **`/push` (In-Cluster Sync)**: Listens for standard git commits/pushes.
2.  **`/release` (Image Build)**: Listens for GitHub Releases (tags).

### The "Brain" (Sensor)
A single **Sensor** (`github-combined-sensor`) processing triggers based on specific logic:

| Scope | Logic | Trigger Action |
| :--- | :--- | :--- |
| **Deploy Sync** | `push` event + **Regex Path Filter** matches modifications to `sample/app/nextcloud.yaml` | **Argo CD Sync**: Force-syncs the `nextcloud-in-cluster` application immediately (via Core mode). |
| **Image Build** | `release` event (Tag created) | **Kaniko Workflow**: Builds a new container image and pushes to GHCR. |

## 2. Directory Structure

```text
sample/
├── events/               # The Event-Driven Logic
│   ├── eventbus.yaml     # Standard NATS implementation
│   ├── eventsource.yaml  # Configures /push and /release endpoints
│   ├── sensor.yaml       # Contains the Filter logic (Regex) and Triggers
│   ├── ingress.yaml      # Exposes Webhooks (events.goeasycare.app)
│   └── rbac.yaml         # Grants the sensor permission to modify Argo CD Applications
├── workflow/             # The Build Logic
│   └── build-push-workflow.yaml # Kaniko WorkflowTemplate
├── app/                  # The Deployment Logic
│   └── nextcloud.yaml    # The main file watched by the "Deploy Sync" trigger
└── argocd/               # The GitOps Logic
    └── applicationset.yaml # Manages multi-cluster deployments
```

## 3. Detailed Logic Implementation

### A. The "Sync Trigger" (Core Mode)
To avoid managing external Argo CLI secrets, the Sync Trigger uses **Core Mode**:
*   **Mechanism**: Uses `argocd app sync --core`.
*   **Authentication**: Bypasses the API server login. Instead, it mounts the standard `argocd-server` (or custom) ServiceAccount directly in the pod to talk to the K8s API.
*   **Target**: Syncs `nextcloud-in-cluster` (local) but leaves `remote-cluster` to handle its own polling/updates.
*   **Filter**: `regex` comparator on `body.commits` list ensures changes are detected even in multi-commit pushes.

### B. The "Build Trigger"
*   **Mechanism**: Standard Argo Workflow.
*   **Credentials**: Uses `docker-config-secret` (mounted as standard `kubernetes.io/dockerconfigjson`) for Kaniko authentication to GHCR.

## 4. RBAC Requirements
To enable this architecture, the ServiceAccount used by the triggers (`operate-workflow-sa`) has enhanced permissions in `sample/events/rbac.yaml`:
*   `argoproj.io/workflows` (Create/Get) -> To start builds.
*   `argoproj.io/applications` (Get/Update/Patch) -> To trigger syncs.

## 5. Deployment Guide

1.  **Secrets**: Ensure `github-access` (for Webhook validation) and `docker-config-secret` (for GHCR) exist in `argocd` namespace.
2.  **Apply Events**:
    ```bash
    kubectl apply -f sample/events/
    ```
3.  **Apply Workflows**:
    ```bash
    kubectl apply -f sample/workflow/
    ```
4.  **Verify**: Check logs of the `sensor` pod to see filters evaluating True/False on GitHub events.
