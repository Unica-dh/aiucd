# Scripts Directory

Utility scripts for WordPress Docker environment management and troubleshooting.

## Available Scripts

### 🔧 `diagnose-permissions.sh`

**Purpose**: Diagnose file permission issues in WordPress Docker setup

**Usage**:
```bash
./scripts/diagnose-permissions.sh
```

**What it does**:
- Shows current user UID/GID
- Checks .env configuration for DOCKER_UID/DOCKER_GID
- Lists WordPress file ownership
- Verifies container process user
- Tests write permissions on critical directories
- Provides specific recommendations

**When to use**:
- WordPress asks for FTP credentials
- Publishing/editing content fails
- After initial deployment
- Before running fix-permissions.sh

---

### 🛠️ `fix-permissions.sh`

**Purpose**: Automatically fix file permission issues

**Usage**:
```bash
./scripts/fix-permissions.sh
```

**What it does**:
- Detects current user UID/GID
- Adds/updates DOCKER_UID and DOCKER_GID in .env
- Stops containers
- Fixes ownership of all WordPress files
- Restarts containers with correct user mapping
- Verifies the fix

**When to use**:
- WordPress shows "La risposta non è una risposta JSON valida"
- After seeing FTP credential requests
- After cloning repository to production
- When diagnose-permissions.sh reports issues

---

### 🚀 `init-wordpress.sh`

**Purpose**: Initial WordPress setup and configuration

**Usage**:
```bash
./scripts/init-wordpress.sh
```

**What it does**:
- Creates necessary directories
- Generates .env from .env.example
- Creates secure random passwords
- Starts containers
- Waits for WordPress to be ready

**When to use**:
- First time setup
- Clean installation

---

### 📊 `manage.sh`

**Purpose**: Common Docker Compose operations wrapper

**Usage**:
```bash
./scripts/manage.sh [command]
```

**Available commands**:
- `start` - Start containers
- `stop` - Stop containers (keeps data)
- `restart` - Stop and start containers
- `down` - Remove containers (keeps volumes)
- `rebuild` - Complete rebuild
- `logs` - Show container logs
- `status` - Show container status

**When to use**:
- Daily operations
- Quick container management
- Checking logs and status

---

### 🧪 `test-deployment.sh`

**Purpose**: Test deployment workflow

**Usage**:
```bash
./scripts/test-deployment.sh
```

**What it does**:
- Simulates GitHub Actions deployment
- Tests health checks
- Validates configuration
- Reports results

**When to use**:
- Before pushing to production
- Testing GitHub Actions workflow locally
- Validating configuration changes

---

## Common Workflows

### First Time Setup
```bash
./scripts/init-wordpress.sh
```

### Fix Permission Issues
```bash
# 1. Diagnose
./scripts/diagnose-permissions.sh

# 2. Fix
./scripts/fix-permissions.sh
```

### Daily Operations
```bash
# Start
./scripts/manage.sh start

# Check logs
./scripts/manage.sh logs

# Restart
./scripts/manage.sh restart
```

### Troubleshooting
```bash
# Check status
./scripts/manage.sh status

# Check permissions
./scripts/diagnose-permissions.sh

# View logs
./scripts/manage.sh logs
```

---

## Notes

- All scripts should be run from the project root directory
- Scripts are designed for both development and production
- Always run `diagnose-permissions.sh` before `fix-permissions.sh`
- Scripts require Docker and Docker Compose installed
