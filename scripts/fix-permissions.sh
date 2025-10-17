#!/bin/bash
# Script per risolvere i problemi di permessi WordPress in produzione
# ESEGUI QUESTO SUL SERVER DI PRODUZIONE

set -e

echo "=========================================="
echo "WORDPRESS PERMISSION FIX SCRIPT"
echo "=========================================="
echo ""

# Check if running in correct directory
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ Error: docker-compose.yml not found"
    echo "   Run this script from the project root directory"
    exit 1
fi

echo "Current directory: $(pwd)"
echo ""

# Get current user info
CURRENT_USER=$(whoami)
CURRENT_UID=$(id -u)
CURRENT_GID=$(id -g)

echo "Current user: $CURRENT_USER (UID: $CURRENT_UID, GID: $CURRENT_GID)"
echo ""

# Check .env file
if [ ! -f .env ]; then
    echo "❌ .env file not found!"
    echo "   Please create .env from .env.example first"
    exit 1
fi

# Check if DOCKER_UID/GID are set
ENV_UID=$(grep "^DOCKER_UID=" .env 2>/dev/null | cut -d'=' -f2)
ENV_GID=$(grep "^DOCKER_GID=" .env 2>/dev/null | cut -d'=' -f2)

if [ -z "$ENV_UID" ] || [ -z "$ENV_GID" ]; then
    echo "⚠️  DOCKER_UID/GID not found in .env"
    echo "   Adding them now..."
    echo "" >> .env
    echo "# Docker User Mapping (for proper file permissions)" >> .env
    echo "DOCKER_UID=$CURRENT_UID" >> .env
    echo "DOCKER_GID=$CURRENT_GID" >> .env
    echo "✅ Added DOCKER_UID=$CURRENT_UID and DOCKER_GID=$CURRENT_GID to .env"
else
    echo "Current .env settings: DOCKER_UID=$ENV_UID, DOCKER_GID=$ENV_GID"
    
    if [ "$ENV_UID" != "$CURRENT_UID" ] || [ "$ENV_GID" != "$CURRENT_GID" ]; then
        echo "⚠️  .env UID/GID don't match current user!"
        read -p "Update .env to use current user UID/GID? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            sed -i "s/^DOCKER_UID=.*/DOCKER_UID=$CURRENT_UID/" .env
            sed -i "s/^DOCKER_GID=.*/DOCKER_GID=$CURRENT_GID/" .env
            echo "✅ Updated .env with DOCKER_UID=$CURRENT_UID and DOCKER_GID=$CURRENT_GID"
        fi
    else
        echo "✅ .env UID/GID already match current user"
    fi
fi
echo ""

# Stop containers
echo "Stopping containers..."
docker compose down
echo ""

# Fix ownership of existing files
if [ -d wordpress ]; then
    echo "Fixing ownership of wordpress/ directory..."
    echo "   This may take a moment for large directories..."
    
    # Use Docker to fix permissions (no sudo needed)
    docker run --rm \
        -v "$(pwd)/wordpress:/workspace" \
        alpine:latest \
        sh -c "chown -R $CURRENT_UID:$CURRENT_GID /workspace"
    
    echo "✅ Ownership fixed"
else
    echo "⚠️  wordpress/ directory not found (will be created on first run)"
fi
echo ""

# Start containers with correct user mapping
echo "Starting containers with user mapping..."
docker compose up -d
echo ""

# Wait for containers to be ready
echo "Waiting for containers to start..."
sleep 5
echo ""

# Check container status
echo "Container status:"
docker compose ps
echo ""

# Verify permissions inside container
echo "Verifying permissions inside container..."
docker compose exec -T wordpress ls -la /var/www/html | head -n 10
echo ""

echo "=========================================="
echo "✅ PERMISSION FIX COMPLETE"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Test WordPress: Try creating/publishing a page"
echo "2. If issues persist, check: docker compose logs wordpress"
echo "3. The WordPress editor should now work without FTP credentials"
echo ""
echo "File ownership: All files in wordpress/ are now owned by UID:$CURRENT_UID GID:$CURRENT_GID"
echo "Container runs as: UID:$CURRENT_UID GID:$CURRENT_GID"
echo "This ensures WordPress can write to all necessary files."
echo ""
