# Copilot Instructions for WordPress Docker Setup

## Project Architecture

This is a **WordPress + MariaDB containerized setup** designed for development and production deployment. Key architectural decisions:

- **Port 8000** (not standard 80) - server-side SSL termination expected
- **No SSL/certificate management** in containers - handled upstream
- **Named Docker volumes** for persistence over bind mounts
- **Internal networking** - database not exposed externally

## Critical Configuration Patterns

### Environment Management
- **Always use `.env` file** for secrets and configuration
- **Never commit `.env`** - provide `.env.example` template
- WordPress secrets auto-generated, database credentials via environment

### Directory Structure Convention
```
├── docker-compose.yml     # Single source of truth for services
├── .env                   # Secrets (gitignored)
├── .env.example          # Template for deployment
├── wordpress/            # Volume mount (auto-generated)
├── database/             # Volume mount (auto-generated)
└── logs/                 # Optional centralized logging
```

## Development Workflows

### Service Management
```bash
# Primary workflow commands
docker-compose up -d              # Start services
docker-compose ps                 # Check status
docker-compose logs -f [service]  # Follow logs
docker-compose down               # Stop services
docker-compose down -v            # DESTRUCTIVE: removes volumes
```

### Key Integration Points
- **WordPress**: Port 8000 → Apache container
- **Database**: Internal network only, accessed via container name
- **phpMyAdmin**: Optional on port 8080 for DB management
- **Volumes**: `wordpress_data` and `db_data` for persistence

## Project-Specific Conventions

### Implementation Phases
1. **Phase 1**: Core WordPress + MariaDB (minimal viable)
2. **Phase 2**: phpMyAdmin, logging, utilities
3. **Phase 3**: Health checks, monitoring, backup strategies

### Docker Compose Patterns
- Use `mariadb:latest` over MySQL for better performance
- `wordpress:latest` includes Apache + PHP (no separate web server)
- Custom bridge network for service isolation
- Named volumes over bind mounts for portability

### Security Approach
- Database accessible only within Docker network
- No exposed database ports to host
- Environment-based configuration separation
- Principle of least privilege for container access

## Essential Commands & Debugging

```bash
# Quick health check
docker-compose ps && curl -s http://localhost:8000 > /dev/null && echo "WordPress OK"

# Database access for debugging
docker-compose exec db mysql -u wordpress -p

# WordPress container shell access
docker-compose exec wordpress bash

# Reset environment (CAREFUL - loses data)
docker-compose down -v && docker-compose up -d
```

## Critical Files to Understand
- `README.md` - Complete project specifications and requirements
- `docker-compose.yml` - Service definitions and networking (when created)
- `.env.example` - All required environment variables (when created)