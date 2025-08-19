# Scenario 2: Terraform with Docker Provider

## Overview

Recreate the Docker Compose deployment from Scenario 1 using Terraform with the Docker provider. This scenario introduces Infrastructure as Code (IaC) principles while maintaining the same Nextcloud stack functionality with persistent data, Redis caching, and database backend.

## Objectives

- Deploy Nextcloud using Terraform and the Docker provider
- Implement the same architecture as Scenario 1 using IaC
- Implement persistent data storage
- Configure Redis for caching
- Set up a database backend (PostgreSQL or MySQL)
- Use named networks and volumes managed by Terraform
- Enable admin access with predefined credentials

## Requirements

### Mandatory Requirements

✅ **MUST use official Nextcloud container**

- Use the official `nextcloud` image from Docker Hub
- Managed through Terraform Docker provider

✅ **MUST include Redis & Database containers**

- Redis container for caching
- Database container (PostgreSQL or MySQL/MariaDB)
- All containers managed by Terraform

✅ **Data MUST persist**

- All data must survive container restarts and recreation
- Use Terraform-managed Docker volumes

✅ **MUST use predefined admin credentials**

- Username: `admin`
- Password: `Password123!`

✅ **MUST support complete teardown and recreation**

- `terraform destroy && terraform apply` should not lose data

✅ **MUST use named networks & volumes**

- No default networks or anonymous volumes
- All resources managed by Terraform

✅ **MUST NOT bind mount except for Nextcloud files**

- Only bind mount your local "nextcloud files" directory
- All other storage must use Terraform-managed Docker volumes

✅ **HTTP is acceptable**

- HTTPS configuration is not required for this scenario

✅ **Secrets MUST NOT be committed to git**

- Use `.tfvars` files or environment variables for sensitive data
- Add `.tfvars` and `.env` to `.gitignore`
- Never commit passwords, tokens, or other secrets

✅ **MUST use Terraform best practices**

- Proper resource dependencies
- Use variables for configuration
- Include outputs for important information
- State management considerations

## Architecture

```mermaid
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Nextcloud     │    │     Redis       │    │   Database      │
│   Container     │◄───┤   Container     │    │   Container     │
│                 │    │                 │    │                 │
│   Port: 8080    │    │   Port: 6379    │    │   Port: 5432    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │  nextcloud-net  │
                    │   (network)     │
                    └─────────────────┘
```

*All resources managed by Terraform*

## Expected Directory Structure

```plaintext
02-docker-terraform/
├── SCENARIO.md              # This file
├── main.tf                  # Main Terraform configuration
├── variables.tf             # Variable definitions
├── outputs.tf               # Output definitions
├── terraform.tfvars.example # Example variables file
├── .env.example             # Example environment file
└── nextcloud-files/         # Local directory for Nextcloud files (bind mount)
```

## Implementation Guidelines

### Terraform Configuration

Your Terraform configuration should include:

1. **Provider Configuration:**
   - Docker provider setup
   - Version constraints

2. **Resources:**
   - `docker_network` - Named network for service communication
   - `docker_volume` - Named volumes for persistence
   - `docker_container` - Nextcloud, Redis, and Database containers
   - `docker_image` - Image resources for all containers

3. **Variables:**
   - Database credentials
   - Nextcloud admin credentials
   - Port configurations
   - Image versions

4. **Outputs:**
   - Nextcloud access URL
   - Container status information
   - Network and volume information

### Container Specifications

#### Nextcloud Container

- **Image:** `nextcloud:latest` or specific version
- **Port:** Expose on `8080` (or configurable)
- **Environment Variables:**
  - `NEXTCLOUD_ADMIN_USER=admin`
  - `NEXTCLOUD_ADMIN_PASSWORD=Password123!`
  - Database and Redis connection details
- **Volumes:**
  - Terraform-managed volumes for Nextcloud HTML/config
  - Terraform-managed volumes for Nextcloud apps
  - Bind mount for `nextcloud-files` directory

#### Redis Container

- **Image:** `redis:alpine` or similar
- **Port:** Internal only (6379)
- **Configuration:** Basic Redis setup for caching

#### Database Container

- **Option 1 - PostgreSQL:**
  - Image: `postgres:15` or similar
  - Environment: `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD`
  - Volume: Terraform-managed volume for data persistence

- **Option 2 - MySQL/MariaDB:**
  - Image: `mariadb:10` or `mysql:8`
  - Environment: `MYSQL_DATABASE`, `MYSQL_USER`, `MYSQL_PASSWORD`, `MYSQL_ROOT_PASSWORD`
  - Volume: Terraform-managed volume for data persistence

## Verification Steps

### 1. Deployment Verification

```bash
# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Apply the configuration
terraform apply

# Verify all containers are running
docker ps

# Check Terraform state
terraform show
```

### 2. Functionality Testing

1. **Access Nextcloud UI:**
   - Navigate to the URL from Terraform outputs
   - Login with credentials: `admin` / `Password123!`

2. **Test File Operations:**
   - Upload a test file through the web interface
   - Verify the file appears in your local `nextcloud-files` directory
   - Create a folder and add files

3. **Test Redis Caching:**
   - Check Redis container logs for cache operations
   - Verify Redis is accessible from Nextcloud container

### 3. Persistence Testing

```bash
# Destroy all resources
terraform destroy

# Re-apply the configuration
terraform apply

# Verify:
# - Can still login with admin credentials
# - All uploaded files are still present
# - No data loss occurred
```

### 4. Terraform State Verification

```bash
# Check Terraform state
terraform state list

# Verify resource status
terraform state show docker_container.nextcloud
terraform state show docker_volume.nextcloud_data
terraform state show docker_network.nextcloud_network
```

## Deliverables

### Required Files

1. **`main.tf`** - Main Terraform configuration
2. **`variables.tf`** - Variable definitions
3. **`outputs.tf`** - Output definitions
4. **`terraform.tfvars.example`** - Example variables file
5. **`.env.example`** - Example environment file
6. **`SCENARIO.md`** - Documentation of your implementation
7. **`nextcloud-files/`** - Local directory for file bind mount

### Documentation Requirements

Include in your implementation SCENARIO.md:

1. **Setup Instructions:**
   - Prerequisites
   - Environment preparation
   - Terraform initialization
   - Deployment steps

2. **Configuration Details:**
   - Resource explanations
   - Variable descriptions
   - Network topology
   - Volume mappings
   - Environment variables used

3. **Usage Guide:**
   - How to deploy/destroy the stack
   - How to access Nextcloud
   - How to verify functionality
   - How to manage Terraform state

4. **Troubleshooting:**
   - Common issues and solutions
   - Log locations
   - Debug commands
   - Terraform-specific issues

## Testing Checklist

Before submitting, verify:

- [ ] All containers start successfully via Terraform
- [ ] Nextcloud web interface is accessible
- [ ] Can login with `admin:Password123!`
- [ ] File uploads work and persist locally
- [ ] Redis is connected and functional
- [ ] Database connection is working
- [ ] Data persists after `terraform destroy/apply`
- [ ] Using named networks only (managed by Terraform)
- [ ] Using named volumes for persistence (managed by Terraform)
- [ ] Only bind mounting `nextcloud-files` directory
- [ ] No anonymous volumes created
- [ ] No secrets committed to git (`.tfvars` in `.gitignore`)
- [ ] Terraform state is properly managed
- [ ] All resources have proper dependencies

## Common Gotchas

### Terraform Provider

- Ensure Docker provider version compatibility
- Docker daemon must be running for Terraform operations
- Provider configuration must be correct

### Resource Dependencies

- Use `depends_on` when implicit dependencies aren't sufficient
- Database must be ready before Nextcloud starts
- Networks must exist before containers are created

### State Management

- Terraform state contains sensitive information
- Never commit `terraform.tfstate` files
- Consider remote state for production scenarios

### Container Lifecycle

- Terraform manages container lifecycle differently than Docker Compose
- Container recreation triggers may differ
- Health checks and readiness probes considerations

## Advanced Options (Optional)

### Resource Dependencies

```hcl
resource "docker_container" "nextcloud" {
  depends_on = [
    docker_container.database,
    docker_container.redis
  ]
  # ... other configuration
}
```

### Data Sources

```hcl
data "docker_image" "nextcloud" {
  name = var.nextcloud_image
}
```

### Local Values

```hcl
locals {
  common_labels = {
    environment = "development"
    project     = "nextcloud-stack"
  }
}
```

## Success Criteria

Your implementation is successful when:

1. All mandatory requirements are met
2. Nextcloud is fully functional via web interface
3. Data persists across Terraform destroy/apply cycles
4. Admin login works with specified credentials
5. File operations work and sync with local directory
6. Clean architecture using Terraform-managed named resources
7. Proper Terraform best practices implemented
8. Documentation is clear and complete
9. State management is properly handled

## Next Steps

Once this scenario is complete, you'll move to Scenario 3 where you'll deploy the same stack on MicroK8s using Terraform with the Kubernetes provider, introducing container orchestration concepts and Kubernetes-specific configurations.
