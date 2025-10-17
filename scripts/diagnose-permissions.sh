#!/bin/bash
# Script di diagnostica permessi WordPress
# Esegui questo sul server di produzione per identificare il problema

echo "=========================================="
echo "WORDPRESS PERMISSION DIAGNOSTIC"
echo "=========================================="
echo ""

echo "1. Current user info:"
echo "   User: $(whoami)"
echo "   UID:  $(id -u)"
echo "   GID:  $(id -g)"
echo ""

echo "2. .env configuration:"
if [ -f .env ]; then
    echo "   DOCKER_UID: $(grep DOCKER_UID .env 2>/dev/null || echo 'NOT SET')"
    echo "   DOCKER_GID: $(grep DOCKER_GID .env 2>/dev/null || echo 'NOT SET')"
else
    echo "   ⚠️  .env file not found!"
fi
echo ""

echo "3. WordPress directory ownership (top 10 files):"
if [ -d wordpress ]; then
    ls -lah wordpress/ | head -n 11
else
    echo "   ⚠️  wordpress/ directory not found!"
fi
echo ""

echo "4. Critical WordPress files ownership:"
for file in wordpress/wp-config.php wordpress/.htaccess wordpress/wp-content; do
    if [ -e "$file" ]; then
        ls -ldh "$file"
    else
        echo "   $file: NOT FOUND"
    fi
done
echo ""

echo "5. Container process user:"
if docker compose ps | grep -q "Up"; then
    echo "   Container www-data UID/GID:"
    docker compose exec -T wordpress id www-data 2>/dev/null || echo "   ⚠️  Cannot query container"
    echo ""
    echo "   Container process user:"
    docker compose exec -T wordpress ps aux | head -n 5
else
    echo "   ⚠️  Containers not running"
fi
echo ""

echo "6. WordPress writable directories check:"
for dir in wordpress/wp-content/uploads wordpress/wp-content/plugins wordpress/wp-content/themes; do
    if [ -d "$dir" ]; then
        echo "   $dir:"
        ls -ldh "$dir"
        # Test write permission
        if touch "$dir/.test-write" 2>/dev/null; then
            echo "      ✅ WRITABLE by current user"
            rm "$dir/.test-write"
        else
            echo "      ❌ NOT WRITABLE by current user"
        fi
    fi
done
echo ""

echo "=========================================="
echo "RECOMMENDATIONS:"
echo "=========================================="
echo ""

CURRENT_UID=$(id -u)
CURRENT_GID=$(id -g)
ENV_UID=$(grep DOCKER_UID .env 2>/dev/null | cut -d'=' -f2)
ENV_GID=$(grep DOCKER_GID .env 2>/dev/null | cut -d'=' -f2)

if [ -z "$ENV_UID" ] || [ -z "$ENV_GID" ]; then
    echo "❌ PROBLEM: DOCKER_UID and DOCKER_GID not set in .env"
    echo ""
    echo "FIX: Add these lines to your .env file:"
    echo ""
    echo "    DOCKER_UID=$CURRENT_UID"
    echo "    DOCKER_GID=$CURRENT_GID"
    echo ""
    echo "Then restart containers:"
    echo "    docker compose down && docker compose up -d"
    echo ""
elif [ "$ENV_UID" != "$CURRENT_UID" ] || [ "$ENV_GID" != "$CURRENT_GID" ]; then
    echo "⚠️  WARNING: .env UID/GID don't match current user"
    echo "   .env has: UID=$ENV_UID GID=$ENV_GID"
    echo "   Current:  UID=$CURRENT_UID GID=$CURRENT_GID"
    echo ""
    echo "If you're the user running the containers, update .env to:"
    echo "    DOCKER_UID=$CURRENT_UID"
    echo "    DOCKER_GID=$CURRENT_GID"
    echo ""
else
    echo "✅ .env UID/GID configuration looks correct"
    echo ""
    echo "If you still have permission issues:"
    echo "1. Check file ownership in wordpress/ directory"
    echo "2. Fix with: docker run --rm -v \$(pwd)/wordpress:/wp alpine:latest chown -R $CURRENT_UID:$CURRENT_GID /wp"
    echo "3. Restart: docker compose down && docker compose up -d"
fi

echo "=========================================="
