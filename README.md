# Nextcloud Deployment Scenarios

## Overview

This repository contains four progressive deployment scenarios for Nextcloud, designed to evaluate and train IT/DevOps professionals on modern infrastructure and deployment practices. Each scenario builds upon the previous one, increasing in complexity and demonstrating different deployment methodologies.

**Note:** This README provides an overview of all scenarios. Detailed instructions, requirements, and implementation guides are provided in each scenario's individual README file.

## Purpose

These scenarios serve as practical assessments for new hires in the IT/DevOps sector, testing skills in:

- Container orchestration
- Database management
- Redis caching
- Kubernetes operations
- Terraform automation

## Prerequisites

Before starting these scenarios, ensure you have the following tools and resources:

### Required Software

- **UTM** (for macOS) or equivalent virtualization software
- **Ubuntu Server** (headless ISO) - for VM setup
- **Docker & Docker Compose** (v20.10+)
- **Terraform** (v1.0+)
- **MicroK8s** (for Scenario 3)
- **kubectl** (for Scenario 3)
- **Git**

### System Requirements

- Sufficient RAM and storage for running VMs (recommended: 8GB+ RAM, 50GB+ storage)
- Stable internet connection for downloading images and dependencies

## Scenarios

Each scenario includes a dedicated README with detailed instructions, requirements, and step-by-step guides.

### Scenario 1: Docker Compose Deployment

**Directory:** `scenarios/01-docker-compose/`

Deploy a complete Nextcloud stack using Docker Compose with PostgreSQL/MySQL database and Redis cache. This scenario focuses on container orchestration fundamentals.

### Scenario 2: Terraform with Docker Provider

**Directory:** `scenarios/02-docker-terraform/`

Recreate the Docker Compose deployment using Terraform's Docker provider. This scenario introduces Infrastructure as Code principles while maintaining the same application stack.

### Scenario 3: MicroK8s with Terraform

**Directory:** `scenarios/03-microk8s-terraform/`

Deploy Nextcloud on MicroK8s using Terraform with custom modules. This advanced scenario covers Kubernetes concepts, persistent storage, and modular Terraform design.

### Scenario 4: MicroK8s Terraform Module

**Directory:** `scenarios/04-microk8s-terraform-module/`

Create a reusable Terraform module for MicroK8s Nextcloud deployments. This expert-level scenario focuses on module design, versioning, and creating infrastructure components that can be shared and reused across different environments.

## Evaluation Criteria

### Technical Implementation (60%)

- **Functionality:** Does the deployment work as expected?
- **Best Practices:** Are industry standards followed?
- **Security:** Are security considerations implemented?
- **Resource Management:** Efficient use of compute and storage resources

### Documentation (20%)

- **Clarity:** Are instructions clear and comprehensive?
- **Completeness:** All necessary steps documented
- **Troubleshooting:** Common issues and solutions provided

### Code Quality (20%)

- **Organization:** Well-structured and readable code
- **Reusability:** Components designed for reuse
- **Version Control:** Proper Git usage and commit messages

## Getting Started

1. **Fork this repository** to your own GitHub account
2. **Clone your fork** locally
3. **Create a new branch** for your work: `git checkout -b your-name-solutions`
4. **Complete scenarios** in order (1 → 2 → 3 → 4)
5. **Document your approach** in each scenario directory
6. **Commit your work** with meaningful commit messages
7. **Create a Pull Request** when complete

## Submission Guidelines

### For Each Scenario

1. Create a `README.md` in the scenario directory explaining:
   - Your approach and design decisions
   - Prerequisites and setup instructions
   - Deployment steps
   - Verification procedures
   - Troubleshooting tips

2. Include all configuration files and scripts

3. Provide cleanup instructions

### Final Submission

- All scenarios completed and documented
- Main README updated with any additional notes
- Pull request created with a summary of your work

## Time Expectations

- **Scenario 1:** 2-4 hours
- **Scenario 2:** 3-5 hours  
- **Scenario 3:** 4-8 hours
- **Scenario 4:** 3-6 hours
- **Total:** 1.5-3 days (depending on experience level)

## Support and Resources

### Useful Documentation

- [Nextcloud Docker Image](https://hub.docker.com/_/nextcloud)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Terraform Docker Provider](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs)
- [Terraform Kubernetes Provider](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs)
- [MicroK8s Documentation](https://microk8s.io/docs)

### Common Gotchas

- Nextcloud requires persistent storage for data and config
- Database initialization may take time on first startup
- Redis doesn't require persistence for caching use case
- MicroK8s may need specific addons enabled (dns, storage, ingress)

## Questions?

If you have questions about the scenarios or need clarification on requirements, please:

1. Check the documentation links provided
2. Review similar implementations online
3. Ask your point of contact for guidance

---

**Good luck with your deployment scenarios! We're excited to see your solutions.**
