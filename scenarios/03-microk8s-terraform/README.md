# Scenario 3: MicroK8s with Terraform

## Overview

Deploy the Nextcloud stack on MicroK8s using Terraform with the Kubernetes provider. This scenario introduces Kubernetes container orchestration concepts while maintaining the same functionality with persistent data, Redis caching, and database backend, but now running on a Kubernetes cluster.

## Objectives

- Deploy Nextcloud using Terraform and the Kubernetes provider
- Implement the same architecture using Kubernetes resources
- Implement persistent data storage using Kubernetes volumes
- Configure Redis for caching
- Set up a database backend (PostgreSQL or MySQL)
- Use Kubernetes services and networking
- Enable admin access with predefined credentials
- Create reusable Terraform modules

## Requirements

### Mandatory Requirements

✅ **MUST use official Nextcloud container**

- Use the official `nextcloud` image from Docker Hub
- Deployed as Kubernetes Deployment via Terraform

✅ **MUST include Redis & Database containers**

- Redis deployment for caching
- Database deployment (PostgreSQL or MySQL/MariaDB)
- All deployments managed by Terraform

✅ **Data MUST persist**

- All data must survive pod restarts and recreation
- Use Kubernetes PersistentVolumes

✅ **MUST use predefined admin credentials**

- Username: `admin`
- Password: `Password123!`

✅ **MUST support complete teardown and recreation**

- `terraform destroy && terraform apply` should not lose data

✅ **MUST use Kubernetes services for networking**

- ClusterIP services for internal communication
- NodePort or LoadBalancer for external access

✅ **MUST NOT bind mount except for Nextcloud files**

- Only use hostPath or local storage for "nextcloud files" directory
- All other storage must use PersistentVolumes

✅ **HTTP is acceptable**

- HTTPS/TLS configuration is not required for this scenario

✅ **Secrets MUST NOT be committed to git**

- Use Kubernetes Secrets or `.tfvars` files for sensitive data
- Add `.tfvars` and `.env` to `.gitignore`
- Never commit passwords, tokens, or other secrets

✅ **MUST use Terraform best practices**

- Proper resource dependencies
- Use variables for configuration
- Include outputs for important information
- State management considerations

✅ **MUST create custom Terraform modules**

- Create reusable modules for Nextcloud, Redis, and Database
- Modules should be parameterized and reusable

## Architecture

```mermaid
┌─────────────────────────────────────────────────────────────┐
│                    MicroK8s Cluster                        │
│                                                             │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐ │
│  │   Nextcloud     │  │     Redis       │  │  Database   │ │
│  │     Pod         │  │      Pod        │  │    Pod      │ │
│  │                 │  │                 │  │             │ │
│  │   Port: 80      │  │   Port: 6379    │  │ Port: 5432  │ │
│  └─────────────────┘  └─────────────────┘  └─────────────┘ │
│           │                     │                   │       │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐ │
│  │  Nextcloud-SVC  │  │   Redis-SVC     │  │Database-SVC │ │
│  │   (NodePort)    │  │  (ClusterIP)    │  │(ClusterIP)  │ │
│  └─────────────────┘  └─────────────────┘  └─────────────┘ │
│           │                     │                   │       │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │              PersistentVolumes                          │ │
│  └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## Expected Directory Structure

```plaintext
03-microk8s-terraform/
├── SCENARIO.md              # This file
├── main.tf                  # Main Terraform configuration
├── variables.tf             # Variable definitions
├── outputs.tf               # Output definitions
├── terraform.tfvars.example # Example variables file
├── modules/                 # Custom Terraform modules
│   ├── nextcloud/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── redis/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── database/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── nextcloud-files/         # Local directory for Nextcloud files
```

## Implementation Guidelines

### Terraform Configuration

Your Terraform configuration should include:

1. **Provider Configuration:**
   - Kubernetes provider setup
   - MicroK8s connection configuration

2. **Module Calls:**
   - Nextcloud module
   - Redis module
   - Database module

3. **Resources:**
   - Namespaces (optional)
   - ConfigMaps
   - Secrets
   - PersistentVolumeClaims
   - Services for external access

4. **Variables:**
   - Kubernetes cluster configuration
   - Database credentials
   - Nextcloud admin credentials
   - Resource limits and requests

5. **Outputs:**
   - Nextcloud access information
   - Service endpoints
   - Pod status information

### Module Specifications

#### Nextcloud Module

- **Deployment:** Nextcloud container deployment
- **Service:** NodePort or LoadBalancer service
- **PVC:** PersistentVolumeClaim for data
- **ConfigMap:** Configuration settings
- **Environment Variables:** Admin credentials, database/Redis connections

#### Redis Module

- **Deployment:** Redis container deployment
- **Service:** ClusterIP service
- **Configuration:** Basic Redis setup for caching

#### Database Module

- **Deployment:** PostgreSQL/MySQL deployment
- **Service:** ClusterIP service
- **PVC:** PersistentVolumeClaim for data
- **Secret:** Database credentials

## Verification Steps

### 1. MicroK8s Setup

```bash
# Ensure MicroK8s is running
microk8s status

# Enable required addons
microk8s enable dns storage

# Configure kubectl
microk8s kubectl config view --raw > ~/.kube/config
```

### 2. Deployment Verification

```bash
# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Apply the configuration
terraform apply

# Verify all pods are running
kubectl get pods

# Check services
kubectl get services

# Check PVCs
kubectl get pvc
```

### 3. Functionality Testing

1. **Access Nextcloud UI:**
   - Get the NodePort from Terraform outputs
   - Navigate to `http://localhost:<nodeport>`
   - Login with credentials: `admin` / `Password123!`

2. **Test File Operations:**
   - Upload a test file through the web interface
   - Verify the file appears in your local `nextcloud-files` directory
   - Create a folder and add files

3. **Test Redis Caching:**
   - Check Redis pod logs for cache operations
   - Verify Redis service connectivity

### 4. Persistence Testing

```bash
# Delete all pods to simulate node failure
kubectl delete pods --all

# Wait for pods to be recreated
kubectl get pods -w

# Verify:
# - Can still login with admin credentials
# - All uploaded files are still present
# - No data loss occurred
```

### 5. Terraform and Kubernetes State Verification

```bash
# Check Terraform state
terraform state list

# Verify Kubernetes resources
kubectl get all
kubectl describe deployment nextcloud
kubectl describe pvc nextcloud-data
```

## Deliverables

### Required Files

1. **`main.tf`** - Main Terraform configuration with module calls
2. **`variables.tf`** - Variable definitions
3. **`outputs.tf`** - Output definitions
4. **`terraform.tfvars.example`** - Example variables file
5. **Custom Modules:**
   - `modules/nextcloud/` - Nextcloud module
   - `modules/redis/` - Redis module
   - `modules/database/` - Database module
6. **`SCENARIO.md`** - Documentation of your implementation
7. **`nextcloud-files/`** - Local directory for file storage

### Documentation Requirements

Include in your implementation SCENARIO.md:

1. **Setup Instructions:**
   - MicroK8s setup and configuration
   - Prerequisites and dependencies
   - Terraform initialization
   - Deployment steps

2. **Architecture Details:**
   - Kubernetes resource explanations
   - Module structure and purpose
   - Service networking
   - Persistent storage strategy
   - Variable descriptions

3. **Usage Guide:**
   - How to deploy/destroy the stack
   - How to access Nextcloud
   - How to scale components
   - How to troubleshoot issues

4. **Module Documentation:**
   - Each module's purpose and inputs
   - Module dependencies
   - Customization options

## Testing Checklist

Before submitting, verify:

- [ ] MicroK8s cluster is properly configured
- [ ] All pods are running and healthy
- [ ] Nextcloud web interface is accessible via NodePort
- [ ] Can login with `admin:Password123!`
- [ ] File uploads work and persist locally
- [ ] Redis is connected and functional
- [ ] Database connection is working
- [ ] Data persists after pod deletion/recreation
- [ ] All services are properly configured
- [ ] PersistentVolumes are working correctly
- [ ] No secrets committed to git (`.tfvars` in `.gitignore`)
- [ ] Terraform modules are properly structured
- [ ] All modules have proper inputs/outputs
- [ ] Resource dependencies are correctly defined

## Common Gotchas

### MicroK8s Configuration

- Ensure required addons are enabled (dns, storage)
- Verify kubectl is properly configured
- Check cluster node status

### Kubernetes Resources

- PersistentVolumes may take time to provision
- Pod startup order matters for database connections
- Resource limits and requests should be properly set

### Terraform Modules

- Module paths must be correct
- Module dependencies should be explicit
- Variable passing between modules

### Networking

- Service discovery uses DNS names
- NodePort ranges are limited (30000-32767)
- ClusterIP services are only accessible within cluster

## Advanced Options (Optional)

### Resource Limits

```hcl
resources {
  limits = {
    cpu    = "500m"
    memory = "512Mi"
  }
  requests = {
    cpu    = "100m"
    memory = "128Mi"
  }
}
```

### Health Checks

```hcl
liveness_probe {
  http_get {
    path = "/status.php"
    port = 80
  }
  initial_delay_seconds = 30
  period_seconds        = 10
}
```

### Storage Classes

```hcl
resource "kubernetes_storage_class" "fast" {
  metadata {
    name = "fast"
  }
  storage_provisioner = "microk8s.io/hostpath"
  parameters = {
    type = "pd-ssd"
  }
}
```

## Success Criteria

Your implementation is successful when:

1. All mandatory requirements are met
2. Nextcloud is fully functional via web interface
3. Data persists across pod recreation
4. Admin login works with specified credentials
5. File operations work and sync with local directory
6. Kubernetes services provide proper networking
7. Custom Terraform modules are well-structured and reusable
8. Documentation is clear and complete
9. State management is properly handled

## Next Steps

Once this scenario is complete, you'll move to Scenario 4 where you'll create a comprehensive, publishable Terraform module that can be shared and reused across different environments and deployments.
