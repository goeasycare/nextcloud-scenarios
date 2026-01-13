variable "namespace" {
  type        = string
  description = "Existing Kubernetes namespace where Nextcloud will be installed (must exist)."
  # Removed default - force explicit namespace to avoid conflicts

  validation {
    condition     = can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.namespace))
    error_message = "Namespace must be a valid Kubernetes resource name (lowercase, alphanumeric, hyphens only)."
  }
}

variable "name" {
  type        = string
  description = "Name for all Kubernetes resources."
  default     = "nextcloud"

  validation {
    condition     = can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.name))
    error_message = "Name must be a valid Kubernetes resource name (lowercase, alphanumeric, hyphens only)."
  }
}

variable "app_label" {
  type        = string
  description = "Value for the 'app' label on all resources."
  default     = "nextcloud"

  validation {
    condition     = can(regex("^[a-zA-Z0-9]([-a-zA-Z0-9_.]*[a-zA-Z0-9])?$", var.app_label))
    error_message = "App label must be a valid Kubernetes label value (alphanumeric, hyphens, underscores, dots allowed)."
  }
}

variable "image" {
  type        = string
  description = "Nextcloud container image."
  default     = "nextcloud:27-apache"

  validation {
    condition     = length(var.image) > 0 && !can(regex("^\\s*$", var.image))
    error_message = "Image must not be empty or contain only whitespace."
  }
}

variable "replicas" {
  type        = number
  description = "Number of Nextcloud replicas."
  default     = 1

  validation {
    condition     = var.replicas >= 0 && var.replicas <= 100
    error_message = "Replicas must be between 0 and 100."
  }
}

variable "container_port" {
  type        = number
  description = "Container port Nextcloud listens on."
  default     = 80

  validation {
    condition     = var.container_port >= 1 && var.container_port <= 65535
    error_message = "Container port must be between 1 and 65535."
  }
}

variable "nextcloud_username" {
  type        = string
  description = "Nextcloud admin username (only used if nextcloud_password is provided)."
  default     = "admin"

  validation {
    condition     = length(var.nextcloud_username) >= 1 && length(var.nextcloud_username) <= 64
    error_message = "Nextcloud username must be between 1 and 64 characters."
  }
}

variable "nextcloud_password" {
  type        = string
  description = "Nextcloud admin password. If null, admin env vars will be skipped."
  sensitive   = true
  default     = null

  validation {
    condition     = var.nextcloud_password == null || length(var.nextcloud_password) >= 8
    error_message = "Nextcloud password must be at least 8 characters long when provided."
  }
}

variable "environment_variables" {
  type = list(object({
    name  = string
    value = string
  }))
  description = "Additional environment variables for Nextcloud container."
  default     = []

  validation {
    condition = alltrue([
      for env_var in var.environment_variables :
      can(regex("^[A-Za-z_][A-Za-z0-9_]*$", env_var.name))
    ])
    error_message = "Environment variable names must be valid (letters, numbers, underscores; cannot start with number)."
  }
}

variable "secret_environment_variables" {
  type = list(object({
    name  = string
    value = string
  }))
  description = "Environment variables from Kubernetes secrets. A single secret will be created automatically containing all variables."
  default     = []
  sensitive   = true

  validation {
    condition = alltrue([
      for env_var in var.secret_environment_variables :
      can(regex("^[A-Za-z_][A-Za-z0-9_]*$", env_var.name))
    ])
    error_message = "Environment variable names must be valid (letters, numbers, underscores; cannot start with number)."
  }
}

variable "service_type" {
  type        = string
  description = "Service type for Nextcloud (ClusterIP, NodePort, LoadBalancer)."
  default     = "NodePort"

  validation {
    condition     = contains(["ClusterIP", "NodePort", "LoadBalancer", "ExternalName"], var.service_type)
    error_message = "Service type must be one of: ClusterIP, NodePort, LoadBalancer, ExternalName."
  }
}

variable "service_port" {
  type        = number
  description = "Service port for Nextcloud."
  default     = 8080

  validation {
    condition     = var.service_port >= 1 && var.service_port <= 65535
    error_message = "Service port must be between 1 and 65535."
  }
}
