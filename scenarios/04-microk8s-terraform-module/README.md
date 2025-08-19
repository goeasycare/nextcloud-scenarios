# Scenario 4: MicroK8s Terraform Module

## Overview

Create a comprehensive, publishable Terraform module for deploying Nextcloud on MicroK8s. This expert-level scenario focuses on advanced module design, versioning, documentation, and creating infrastructure components that can be shared and reused across different environments and teams.

## Objectives

- Design a professional-grade Terraform module
- Implement module versioning and release practices
- Create comprehensive documentation and examples
- Support multiple deployment scenarios and configurations
- Implement proper testing and validation
- Follow Terraform module best practices
- Enable community contribution and maintenance

## Requirements

### Mandatory Requirements

✅ **MUST use official Nextcloud container**

- Use the official `nextcloud` image from Docker Hub
- Support configurable image versions

✅ **MUST include Redis & Database containers**

- Redis deployment for caching
- Database deployment (PostgreSQL or MySQL/MariaDB)
- Support for external database connections

✅ **Data MUST persist**

- All data must survive pod restarts and recreation
- Use Kubernetes PersistentVolumes
- Support different storage classes

✅ **MUST use predefined admin credentials**

- Username: `admin`
- Password: `Password123!`
- Support custom admin credentials via variables

✅ **MUST support complete teardown and recreation**

- `terraform destroy && terraform apply` should not lose data

✅ **MUST use Kubernetes services for networking**

- ClusterIP services for internal communication
- Configurable external access (NodePort/LoadBalancer/Ingress)

✅ **HTTP is acceptable**

- HTTPS/TLS configuration is optional but supported

✅ **Secrets MUST NOT be committed to git**

- Use Kubernetes Secrets for sensitive data
- Provide secure credential management
- Never commit passwords, tokens, or other secrets

✅ **MUST follow Terraform module standards**

- Proper module structure and organization
- Comprehensive variable validation
- Meaningful outputs
- Resource tagging and labeling

✅ **MUST create a publishable module**

- Module should be ready for Terraform Registry
- Include proper versioning (semantic versioning)
- Comprehensive README and documentation
- Working examples and test cases
- CI/CD pipeline for testing (optional)

✅ **MUST support multiple environments**

- Development, staging, production configurations
- Environment-specific resource sizing
- Configurable features and add-ons

## Architecture

```mermaid
┌─────────────────────────────────────────────────────────────┐
│                  Terraform Module                          │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │               MicroK8s Cluster                          │ │
│  │                                                         │ │
│  │  ┌─────────────────┐  ┌─────────────────┐  ┌─────────┐ │ │
│  │  │   Nextcloud     │  │     Redis       │  │Database │ │ │
│  │  │     Pod         │  │      Pod        │  │   Pod   │ │ │
│  │  │                 │  │                 │  │         │ │ │
│  │  │   Port: 80      │  │   Port: 6379    │  │Port:5432│ │ │
│  │  └─────────────────┘  └─────────────────┘  └─────────┘ │ │
│  │           │                     │                │     │ │
│  │  ┌─────────────────┐  ┌─────────────────┐  ┌─────────┐ │ │
│  │  │  Nextcloud-SVC  │  │   Redis-SVC     │  │DB-SVC   │ │ │
│  │  │ (Configurable)  │  │  (ClusterIP)    │  │(ClusterIP)│ │ │
│  │  └─────────────────┘  └─────────────────┘  └─────────┘ │ │
│  │           │                     │                │     │ │
│  │  ┌─────────────────────────────────────────────────────┐ │ │
│  │  │            PersistentVolumes                        │ │ │
│  │  │         (Configurable Storage Classes)              │ │ │
│  │  └─────────────────────────────────────────────────────┘ │ │
│  └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## Expected Directory Structure

```plaintext
04-microk8s-terraform-module/
├── SCENARIO.md              # This file
├── README.md                # Module documentation
├── main.tf                  # Main module configuration
├── variables.tf             # Variable definitions with validation
├── outputs.tf               # Output definitions
├── versions.tf              # Provider version constraints
├── CHANGELOG.md             # Version changelog
├── LICENSE                  # Module license
├── examples/                # Usage examples
│   ├── basic/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── production/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── with-ingress/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── modules/                 # Sub-modules
│   ├── nextcloud/
│   ├── redis/
│   └── database/
├── test/                    # Test cases
│   ├── basic_test.go
│   └── production_test.go
└── docs/                    # Additional documentation
    ├── CONTRIBUTING.md
    ├── SECURITY.md
    └── TROUBLESHOOTING.md
```

## Implementation Guidelines

### Module Structure

Your Terraform module should follow these standards:

1. **Root Module:**
   - Clean, well-documented main.tf
   - Comprehensive variables.tf with validation
   - Meaningful outputs.tf
   - Provider version constraints in versions.tf

2. **Sub-modules:**
   - Separate modules for major components
   - Reusable and independently testable
   - Clear interfaces and documentation

3. **Examples:**
   - Multiple working examples
   - Different complexity levels
   - Real-world use cases

4. **Documentation:**
   - README with usage examples
   - Variable and output documentation
   - Architecture diagrams
   - Troubleshooting guides

### Module Features

#### Core Features

- Full Nextcloud deployment on Kubernetes
- Redis caching integration
- Database backend (PostgreSQL/MySQL)
- Persistent storage management
- Service configuration
- Security and secrets management

#### Advanced Features

- Multi-environment support
- Resource scaling and limits
- Storage class selection
- Network policy support
- Backup and restore capabilities
- Monitoring and logging integration
- High availability configuration

#### Configuration Options

- Database type selection (PostgreSQL/MySQL/External)
- Storage backend options
- Security configurations
- Resource limits and requests
- Feature toggles
- Custom labels and annotations

## Module Requirements

### Variable Validation

```hcl
variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "nextcloud_admin_password" {
  description = "Admin password for Nextcloud"
  type        = string
  sensitive   = true
  validation {
    condition     = length(var.nextcloud_admin_password) >= 12
    error_message = "Admin password must be at least 12 characters long."
  }
}
```

### Resource Tagging

```hcl
locals {
  common_labels = {
    "app.kubernetes.io/name"       = "nextcloud"
    "app.kubernetes.io/instance"   = var.instance_name
    "app.kubernetes.io/version"    = var.nextcloud_version
    "app.kubernetes.io/component"  = "nextcloud"
    "app.kubernetes.io/part-of"    = "nextcloud-stack"
    "app.kubernetes.io/managed-by" = "terraform"
    "environment"                  = var.environment
  }
}
```

### Outputs

```hcl
output "nextcloud_url" {
  description = "URL to access Nextcloud"
  value       = "http://${var.cluster_ip}:${local.nodeport}"
}

output "admin_credentials" {
  description = "Admin credentials for Nextcloud"
  value = {
    username = var.nextcloud_admin_user
    password = var.nextcloud_admin_password
  }
  sensitive = true
}
```

## Verification Steps

### 1. Module Development Testing

```bash
# Test basic example
cd examples/basic
terraform init
terraform plan
terraform apply

# Test production example
cd ../production
terraform init
terraform plan
terraform apply

# Test with ingress
cd ../with-ingress
terraform init
terraform plan
terraform apply
```

### 2. Module Validation

```bash
# Validate Terraform syntax
terraform validate

# Format code
terraform fmt -recursive

# Check with tflint (if available)
tflint

# Check security with tfsec (if available)
tfsec .
```

### 3. Documentation Generation

```bash
# Generate documentation (terraform-docs)
terraform-docs markdown table --output-file README.md .

# Validate examples
for example in examples/*/; do
  cd "$example"
  terraform validate
  cd -
done
```

## Deliverables

### Required Files

1. **Module Core:**
   - `main.tf` - Main module logic
   - `variables.tf` - All variables with validation
   - `outputs.tf` - Module outputs
   - `versions.tf` - Provider constraints
   - `README.md` - Comprehensive module documentation

2. **Examples:**
   - `examples/basic/` - Simple deployment example
   - `examples/production/` - Production-ready example
   - `examples/with-ingress/` - Advanced networking example

3. **Documentation:**
   - `CHANGELOG.md` - Version history
   - `LICENSE` - Module license
   - `docs/CONTRIBUTING.md` - Contribution guidelines
   - `docs/TROUBLESHOOTING.md` - Common issues and solutions

4. **Testing:**
   - Test cases for different scenarios
   - Validation scripts

5. **Implementation Documentation:**
   - `SCENARIO.md` - Your implementation approach and decisions

### Documentation Requirements

Include in your implementation SCENARIO.md:

1. **Design Decisions:**
   - Module architecture choices
   - Trade-offs and considerations
   - Security design principles

2. **Usage Instructions:**
   - How to use the module
   - Configuration options
   - Example use cases

3. **Development Process:**
   - How you structured the module
   - Testing approach
   - Validation methods

4. **Module Features:**
   - Supported configurations
   - Optional features
   - Customization options

## Testing Checklist

Before submitting, verify:

- [ ] Module follows Terraform best practices
- [ ] All variables have proper validation
- [ ] All outputs are documented and meaningful
- [ ] Examples work and are well-documented
- [ ] README is comprehensive and auto-generated
- [ ] Module supports multiple environments
- [ ] Security best practices are implemented
- [ ] Resource tagging is consistent
- [ ] Module is version constrained
- [ ] No secrets are committed to git
- [ ] Module can be published to Terraform Registry
- [ ] All features work as documented
- [ ] Error handling is robust
- [ ] Module is backwards compatible

## Advanced Features (Expert Level)

### Conditional Resources

```hcl
resource "kubernetes_ingress_v1" "nextcloud" {
  count = var.enable_ingress ? 1 : 0
  # ... ingress configuration
}
```

### Dynamic Blocks

```hcl
dynamic "rule" {
  for_each = var.ingress_rules
  content {
    host = rule.value.host
    http {
      path {
        path = rule.value.path
        backend {
          service {
            name = kubernetes_service.nextcloud.metadata[0].name
            port {
              number = 80
            }
          }
        }
      }
    }
  }
}
```

### Module Composition

```hcl
module "nextcloud" {
  source = "./modules/nextcloud"
  
  namespace = kubernetes_namespace.nextcloud.metadata[0].name
  labels    = local.common_labels
  
  # Pass through relevant variables
  image_version = var.nextcloud_version
  admin_user    = var.admin_user
  admin_password = var.admin_password
}
```

## Success Criteria

Your implementation is successful when:

1. Module is professionally structured and documented
2. All examples work out of the box
3. Module supports multiple environments and configurations
4. Security best practices are implemented throughout
5. Module can be published to Terraform Registry
6. Documentation is comprehensive and auto-generated
7. Testing validates all major use cases
8. Module follows semantic versioning
9. Code quality meets enterprise standards
10. Module is ready for community contribution

## Bonus Points

Consider implementing:

- [ ] Automated testing with GitHub Actions or similar
- [ ] Integration with Terraform Cloud/Enterprise
- [ ] Support for Helm charts as an alternative
- [ ] Backup and disaster recovery features
- [ ] Monitoring and alerting integration
- [ ] Multi-cloud compatibility
- [ ] Performance optimization options
- [ ] Security scanning integration

## Publication Ready

Your module should be ready to:

- Publish to Terraform Registry
- Share with the community
- Use in production environments
- Maintain and evolve over time
- Accept community contributions

This scenario represents the culmination of your Terraform and Kubernetes skills, demonstrating your ability to create enterprise-grade infrastructure modules.
