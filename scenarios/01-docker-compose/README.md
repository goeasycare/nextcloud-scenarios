# Scenario 1: Docker Compose Deployment

## Overview

Deploy a complete Nextcloud stack using Docker Compose with persistent data, Redis caching, and database backend. This scenario focuses on container orchestration fundamentals using Docker Compose.

## Objectives

- Deploy Nextcloud using the official Docker image
- Implement persistent data storage
- Configure Redis for caching
- Set up a database backend (PostgreSQL or MySQL)
- Use named networks and volumes for proper container isolation
- Enable admin access with predefined credentials

## Requirements

### Mandatory Requirements

✅ **MUST use official Nextcloud container**

- Use the official `nextcloud` image from Docker Hub

✅ **MUST include Redis & Database containers**

- Redis container for caching
- Database container (PostgreSQL or MySQL/MariaDB)

✅ **Data MUST persist**

- All data must survive container restarts and recreation

✅ **MUST use predefined admin credentials**

- Username: `admin`
- Password: `Password123!`

✅ **MUST support complete teardown and recreation**

- `docker-compose down && docker-compose up` should not lose data

✅ **MUST use named networks & volumes**

- No default networks or anonymous volumes

✅ **MUST NOT bind mount except for Nextcloud files**

- Only bind mount your local "nextcloud files" directory
- All other storage must use Docker volumes

✅ **HTTP is acceptable**

- HTTPS configuration is not required for this scenario

✅ **Secrets MUST NOT be committed to git**

- Use `.env` files or environment variables for sensitive data
- Add `.env` to `.gitignore`
- Never commit passwords, tokens, or other secrets

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

## Expected Directory Structure

```plaintext
01-docker-compose/
├── README.md              # This file
├── SCENARIO.md            # Create this file with your implementation details
├── docker-compose.yml     # Main compose file
├── .env                   # Environment variables (optional)
└── nextcloud-files/       # Local directory for Nextcloud files (bind mount)
```

## Implementation Guidelines

### Docker Compose Configuration

Your `docker-compose.yml` should include:

1. **Services:**
   - `nextcloud` - Official Nextcloud container
   - `redis` - Redis cache container
   - `database` - PostgreSQL or MySQL/MariaDB container

2. **Networks:**
   - Named network for service communication
   - No services should use the default network

3. **Volumes:**
   - Named volumes for database data
   - Named volumes for Nextcloud data (config, apps, etc.)
   - Bind mount only for Nextcloud files directory

4. **Environment Variables:**
   - Database connection settings
   - Redis connection settings
   - Admin user credentials

### Container Specifications

#### Nextcloud Container

- **Image:** `nextcloud:latest` or specific version
- **Port:** Expose on `8080` (or your choice)
- **Environment Variables:**
  - `NEXTCLOUD_ADMIN_USER=admin`
  - `NEXTCLOUD_ADMIN_PASSWORD=Password123!`
  - Database and Redis connection details
- **Volumes:**
  - Named volume for Nextcloud HTML/config
  - Named volume for Nextcloud apps
  - Bind mount for `nextcloud-files` directory

#### Redis Container

- **Image:** `redis:alpine` or similar
- **Port:** Internal only (6379)
- **Configuration:** Basic Redis setup for caching

#### Database Container

- **Option 1 - PostgreSQL:**
  - Image: `postgres:15` or similar
  - Environment: `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD`
  - Volume: Named volume for data persistence

- **Option 2 - MySQL/MariaDB:**
  - Image: `mariadb:10` or `mysql:8`
  - Environment: `MYSQL_DATABASE`, `MYSQL_USER`, `MYSQL_PASSWORD`, `MYSQL_ROOT_PASSWORD`
  - Volume: Named volume for data persistence

## Verification Steps

### 1. Deployment Verification

```bash
# Start the stack
docker-compose up -d

# Verify all containers are running
docker-compose ps

# Check logs for any errors
docker-compose logs
```

### 2. Functionality Testing

1. **Access Nextcloud UI:**
   - Navigate to `http://localhost:8080` (or your configured port)
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
# Stop all containers
docker-compose down

# Start again
docker-compose up -d

# Verify:
# - Can still login with admin credentials
# - All uploaded files are still present
# - No data loss occurred
```

### 4. Network and Volume Verification

```bash
# Check named networks
docker network ls | grep nextcloud

# Check named volumes
docker volume ls | grep nextcloud

# Verify no anonymous volumes exist
docker volume ls
```

## Deliverables

### Required Files

1. **`docker-compose.yml`** - Complete Docker Compose configuration
2. **`SCENARIO.md`** - Documentation of your implementation
3. **`.env`** (optional) - Environment variables file
4. **`nextcloud-files/`** - Local directory for file bind mount

### Documentation Requirements

Include in your implementation SCENARIO.md:

1. **Setup Instructions:**
   - Prerequisites
   - Environment preparation
   - Deployment steps

2. **Configuration Details:**
   - Service explanations
   - Network topology
   - Volume mappings
   - Environment variables used

3. **Usage Guide:**
   - How to start/stop the stack
   - How to access Nextcloud
   - How to verify functionality

4. **Troubleshooting:**
   - Common issues and solutions
   - Log locations
   - Debug commands

## Testing Checklist

Before submitting, verify:

- [ ] All containers start successfully
- [ ] Nextcloud web interface is accessible
- [ ] Can login with `admin:Password123!`
- [ ] File uploads work and persist locally
- [ ] Redis is connected and functional
- [ ] Database connection is working
- [ ] Data persists after `docker-compose down/up`
- [ ] Using named networks only
- [ ] Using named volumes for persistence
- [ ] Only bind mounting `nextcloud-files` directory
- [ ] No anonymous volumes created
- [ ] No secrets committed to git (`.env` in `.gitignore`)

## Common Gotchas

### Database Initialization

- Database containers may take time to initialize on first startup
- Nextcloud may fail to connect initially - this is normal
- Use `depends_on` and health checks if needed

### File Permissions

- Ensure your local `nextcloud-files` directory has correct permissions
- Container user may need specific UID/GID mappings

### Network Connectivity

- All services must be on the same named network
- Use service names for inter-container communication
- Don't expose unnecessary ports to the host

### Volume Management

- Named volumes persist across container recreations
- Anonymous volumes should be avoided
- Check volume ownership and permissions

## Advanced Options (Optional)

### Health Checks

Add health checks to ensure services are ready before Nextcloud starts:

```yaml
healthcheck:
  test: ["CMD", "pg_isready", "-U", "postgres"]
  interval: 30s
  timeout: 10s
  retries: 3
```

### Resource Limits

Consider adding resource constraints:

```yaml
deploy:
  resources:
    limits:
      memory: 512M
      cpus: '0.5'
```

### Backup Strategy

Document how to backup and restore:

- Database dumps
- Volume snapshots
- Configuration exports

## Success Criteria

Your implementation is successful when:

1. All mandatory requirements are met
2. Nextcloud is fully functional via web interface
3. Data persists across container lifecycle
4. Admin login works with specified credentials
5. File operations work and sync with local directory
6. Clean architecture using named resources
7. Documentation is clear and complete

## Next Steps

Once this scenario is complete, you'll move to Scenario 2 where you'll recreate this same deployment using Terraform with the Docker provider, maintaining the same functionality while introducing Infrastructure as Code principles.
