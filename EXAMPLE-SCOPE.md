# Nextcloud GitOps MWE - Implementation Guide

This document outlines the architecture, setup steps, and configuration required to deploy the Minimum Working Example (MWE) located in the `sample/` directory.

## Architecture

This MWE implements a full CI/CD pipeline using the Argo suite:

1.  **Trigger**: A **GitHub Release** (published) sends a webhook to **Argo Events**.
2.  **Pipeline**: **Argo Events** triggers an **Argo Workflow**.
3.  **Build**: The **Argo Workflow**:
    *   Clones the repository at the release tag.
    *   Builds the Nextcloud container image using Kaniko.
    *   Pushes the image to **GitHub Container Registry (GHCR)**.
    *   *(Future Extension)*: Updates the GitOps manifest to pin the new version.
4.  **Deployment**: **Argo CD** manages an **ApplicationSet** that deploys the full stack:
    *   **Nextcloud** (Application)
    *   **Redis** (Cache)
    *   **PostgreSQL** (Database)

## Step 1: Pre-requisites & GitHub Secrets Setup

Before deploying any Kubernetes resources, you must generate the necessary credentials from GitHub and configure them in your cluster.

### 1. Generate GitHub Personal Access Token (PAT)
You need a PAT to allow the cluster to pull code and push images.

1.  Go to [GitHub Developer Settings > Tokens](https://github.com/settings/tokens).
2.  Generate a **New Token (Classic)**.
3.  **Scopes needed**:
    *   `repo` (Full control of private repositories) - *Required if your repo is private.*
    *   `write:packages` (Upload packages to GitHub Package Registry) - *Required to push the Docker image.*
    *   `read:packages` (Download packages from GitHub Package Registry).
    *   `admin:repo_hook` (Optional, helpful for managing webhooks).
4.  **Copy the token**. You will not see it again.

### 2. Create Kubernetes Secrets
These commands must be run in the cluster namespace where you install the Argo tools (usually `argocd` or `argo-events`).

**A. Docker Config Secret (For pushing images to GHCR)**
Replace the placeholders with your details.
```bash
# REPLACEMENT REQUIRED:
# <YOUR_USERNAME>: Your GitHub username
# <YOUR_PAT>: The token you just generated
# <YOUR_EMAIL>: Your email address
kubectl create secret docker-registry docker-config-secret \
  --docker-server=ghcr.io \
  --docker-username=<YOUR_USERNAME> \
  --docker-password=<YOUR_PAT> \
  --docker-email=<YOUR_EMAIL> \
  -n argocd
```

**B. Webhook Secret (For validating GitHub Events)**
Decide on a random string (e.g., "my-super-secret-string"). You will use this in both the Kubernetes secret and the GitHub Webhook settings.
```bash
# REPLACEMENT REQUIRED:
# <YOUR_WEBHOOK_SECRET>: Your chosen random string
kubectl create secret generic github-access \
  --from-literal=secret=<YOUR_WEBHOOK_SECRET> \
  -n argocd
```

**C. Git Credentials Secret (For updating GitOps manifests)**
This secret is used by the workflow to clone the repository, update the kustomization.yaml, and push changes back to GitHub.
```bash
# REPLACEMENT REQUIRED:
# <YOUR_USERNAME>: Your GitHub username
# <YOUR_PAT>: The token you generated in step 1 (must have repo write access)
# Create a temporary directory
mkdir -p /tmp/git-secret

# Create .git-credentials file
cat > /tmp/git-secret/.git-credentials <<EOF
https://<YOUR_USERNAME>:<YOUR_PAT>@github.com
EOF

# Create .gitconfig file
cat > /tmp/git-secret/.gitconfig <<EOF
[credential]
    helper = store
EOF

# Create the Kubernetes secret
kubectl create secret generic git-creds \
  --from-file=.git-credentials=/tmp/git-secret/.git-credentials \
  --from-file=.gitconfig=/tmp/git-secret/.gitconfig \
  -n argocd

# Clean up
rm -rf /tmp/git-secret
```


## Step 2: Configuration TODOs

The files in `sample/` contain `TODO` placeholders. You must update them to match your project.

### Open and Edit the following files:

1.  **`sample/events/eventsource.yaml`**
    *   [ ] `owner`: Set to your GitHub Organization or Username.
    *   [ ] `repository`: Set to `nextcloud-scenarios`.
    *   [ ] `url`: Set to the external ingress URL where Argo Events is listening (e.g., `https://events.example.com/release`).

2.  **`sample/workflow/build-push-workflow.yaml`**
    *   [ ] `--destination` (x2): Updates the GHCR paths. Replace `TODO_OWNER` and `TODO_CONTENT_IMAGE` with your details (e.g., `myuser/nextcloud-custom`).

3.  **`sample/app/kustomization.yaml`**
    *   [ ] `images.name`: Replace `ghcr.io/TODO_OWNER/TODO_CONTENT_IMAGE` with the exact image name defined in the workflow above.
    *   [ ] `images.newName`: Same as above.

4.  **`sample/app/nextcloud.yaml`**
    *   [ ] `image`: Replace the placeholder `ghcr.io/TODO_OWNER/TODO_CONTENT_IMAGE` with your image name.

5.  **`sample/argocd/applicationset.yaml`**
    *   [ ] `repoURL`: Update to the HTTPS URL of *this* repository (e.g., `https://github.com/goeasycare/nextcloud-scenarios.git`).

## Step 3: Deployment Instructions

Once configuration is complete, deploy the resources.

1.  **Deploy Events Infrastructure**:
    ```bash
    kubectl apply -f sample/events/ -n argocd
    ```

2.  **Setup GitHub Webhook**:
    *   Go to your GitHub Repository Settings > Webhooks.
    *   **Payload URL**: The URL you configured in `eventsource.yaml`.
    *   **Content type**: `application/json`.
    *   **Secret**: The `<YOUR_WEBHOOK_SECRET>` from Step 1.
    *   **Events**: Select "Let me select individual events" -> check **Releases**.

3.  **Deploy Workflow Infrastructure**:
    ```bash
    kubectl apply -f sample/workflow/ -n argocd
    ```

4.  **Deploy ApplicationSet**:
    ```bash
    kubectl apply -f sample/argocd/ -n argocd
    ```

## Step 4: Verification

1.  Create a **new Release** in GitHub (e.g., `v1.0.0`).
2.  Check **Argo Events** logs to see the event trigger.
3.  Check **Argo Workflows** UI/CLI to see the `nextcloud-build-Push` workflow running.
4.  Once built, check **Argo CD** to see the `nextcloud-stack` application syncing.

