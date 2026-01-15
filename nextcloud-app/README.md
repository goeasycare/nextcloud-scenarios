# Nextcloud GitOps Scenarios

This directory contains the Kubernetes manifests for deploying Nextcloud with PostgreSQL and Redis, designed for GitOps deployment using Argo CD.

## Architecture

The application stack consists of three main components:

1.  **Nextcloud**: The application frontend (Deployment).
2.  **PostgreSQL**: The database backend (StatefulSet).
3.  **Redis**: Caching layer for performance (Deployment).

## Directory Structure

`nextcloud-app/nextcloud/` contains the plain YAML manifests:

*   `00-namespace.yaml`: creates the `nextcloud` namespace.
*   `nextcloud.yaml`: Deployment and Service for Nextcloud.
*   `postgres.yaml`: StatefulSet and Service for PostgreSQL.
*   `redis.yaml`: Deployment and Service for Redis.
*   `ingress.yaml`: Ingress configuration with cert-manager annotations.
*   `pvc.yaml`: PersistentVolumeClaims for all components.
*   `secrets.yaml`: Secrets for database and admin credentials.

## Deployment via Argo CD

This repository is structured to be deployed via Argo CD.

1.  **Application Manifest**: The Argo CD Application definition is located at `applications/app.yaml`.
2.  **Project**: The AppProject definition is at `projects/not-default.yaml`.

To deploy:

```bash
kubectl apply -f projects/not-default.yaml
kubectl apply -f applications/app.yaml
```

## Configuration

### Secrets

**Note**: The `secrets.yaml` file currently contains unencrypted secrets for demonstration purposes. In a production environment, you should use SealedSecrets, External Secrets Operator, or a prompt secret management solution.

Keys required in `nextcloud-secrets`:
*   `postgres-password`
*   `redis-password`
*   `NEXTCLOUD_ADMIN_USER`
*   `NEXTCLOUD_ADMIN_PASSWORD`

### Storage

Three Persistent Volume Claims are created:
*   `nextcloud-data`: 10Gi for application files.
*   `postgres-data`: 8Gi for database storage.
*   `redis-data`: 2Gi for cache data.

### Ingress

The generic Ingress resource is configured for `nextcloud.goeasycare.app`. It assumes the existence of:
*   An NGINX Ingress Controller.
*   Cert-Manager (configured with a `ClusterOriginIssuer`).
*   ExternalDNS (optional, but configured via annotations).
