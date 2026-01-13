# Nextcloud Improved Module

This is an improved version of the original nextcloud module with significant architectural and usability enhancements.

## Key Improvements Made

### 🏗️ **Namespace Management**

- **Removed internal namespace creation** to prevent deployment conflicts
- **Requires explicit namespace** as input (no default) to avoid accidental deployments
- **Prevents ordering issues** when deploying multiple modules in same namespace
- **Added namespace validation** to ensure Kubernetes naming compliance

### 🔧 **Resource Naming & Flexibility**

- **Added `name` variable** to customize all resource names (default: "nextcloud")
- **Added `app_label` variable** to customize app label values (default: "nextcloud")
- **Eliminated hardcoded resource names** for better reusability
- **Added naming validation** for both resource names and labels

### 🔌 **Port Configuration**

- **Added `container_port` variable** with configurable default (80)
- **Centralized port management** using local values
- **Removed hardcoded port references** in multiple locations
- **Added port range validation** (1-65535)

### 🔐 **Enhanced Secret Management**

- **Added automatic secret creation** when `secret_environment_variables` provided OR admin password provided
- **Single secret approach** - creates one secret containing all variables
- **Simplified variable structure** - only requires `name` and `value`
- **Smart secret referencing** - automatically uses created secret
- **Admin credentials automatically secured** - admin user/password stored in secrets, never as plain text
- **Added secret output** for external reference

### 🌐 **Environment Variable Flexibility**

- **Added `environment_variables`** for plain-text environment variables
- **Added `secret_environment_variables`** for secure variables
- **Dynamic environment variable blocks** using for_each loops
- **Conditional admin credentials** - only added when password provided
- **Support for different Nextcloud images** (official, Bitnami, custom)
- **Added environment variable name validation**

### 🛡️ **Input Validation & Security**

- **Eliminated security vulnerability** - admin credentials never stored as plain text environment variables
- **Automatic secret storage** - admin user/password automatically placed in Kubernetes secrets
- **Added comprehensive validation rules** to all variables:
  - Kubernetes naming conventions for names/namespaces/labels
  - Port ranges (1-65535)
  - Replica limits (0-100)
  - Password minimum length (8 characters)
  - Environment variable naming rules
  - Service type enumeration
  - Non-empty image validation
  - Username length limits (1-64 characters)
- **Made admin password optional** with null default
- **Added sensitive flag** to secret variables

### 📊 **Improved Outputs**

- **Added `created_secrets` output** with secret metadata
- **Conditional output logic** - returns null when no secrets created
- **Retained original `service_name` output** for backward compatibility

### 🔄 **Code Quality Improvements**

- **Removed unnecessary local variables** where logic can be inline
- **Added resource dependencies** to ensure proper creation order
- **Improved comments and documentation** throughout code
- **Consistent resource labeling** across all components
- **Eliminated magic numbers and strings**

## Migration from Original Module

### **Breaking Changes:**

- `namespace` parameter now required (no default)
- Admin credentials now optional (set `nextcloud_password = null` to skip)

### **New Capabilities:**

- Automatic secret creation
- Custom resource naming
- Additional environment variables
- Enhanced validation
- Flexible port configuration

### **Backward Compatibility:**

- All original functionality preserved when using equivalent settings
- Service outputs remain the same
- Core deployment behavior unchanged

## Usage Examples

### **Basic Usage (Improved)**

```terraform
module "nextcloud" {
  source = "./modules/nextcloud-improved"
  
  namespace          = "my-apps"  # Now required
  name              = "my-nextcloud"
  nextcloud_password = var.admin_password  # Automatically stored in secret (secure)
}
```

### **With Automatic Secrets**

```terraform
module "nextcloud" {
  source = "./modules/nextcloud-improved"
  
  namespace = "my-apps"
  
  secret_environment_variables = [
    {
      name  = "NEXTCLOUD_ADMIN_USER"
      value = "admin"
    },
    {
      name  = "NEXTCLOUD_ADMIN_PASSWORD" 
      value = var.admin_password
    }
  ]
}
```

### **Custom Configuration**

```terraform
module "nextcloud" {
  source = "./modules/nextcloud-improved"
  
  namespace      = "production"
  name          = "file-server"
  app_label     = "file-sharing"
  container_port = 8080
  replicas      = 3
  
  environment_variables = [
    {
      name  = "NEXTCLOUD_DATA_DIR"
      value = "/var/www/html/data"
    }
  ]
}
```

## Summary

The improved module transforms a basic deployment script into a production-ready, flexible, and secure Terraform module with comprehensive validation, **automatic credential security**, and significantly improved usability while maintaining backward compatibility. **Critical security improvement**: Admin credentials are now automatically stored in Kubernetes secrets instead of being exposed as plain text environment variables.
