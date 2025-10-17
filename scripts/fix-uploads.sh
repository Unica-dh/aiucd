#!/bin/bash
# Fix WordPress uploads directory permissions

set -e

echo "=========================================="
echo "WORDPRESS UPLOADS PERMISSION FIX"
echo "=========================================="
echo ""

if [ ! -f "docker-compose.yml" ]; then
    echo "❌ Error: Run this from the project root directory"
    exit 1
fi

echo "Checking containers status..."
if ! docker compose ps | grep -q "Up"; then
    echo "❌ Containers not running. Start them first with: docker compose up -d"
    exit 1
fi
echo "✅ Containers are running"
echo ""

CURRENT_UID=$(id -u)
CURRENT_GID=$(id -g)

echo "Current user: $(whoami) (UID: $CURRENT_UID, GID: $CURRENT_GID)"
echo ""

echo "Step 1: Checking uploads directory..."
if docker compose exec -T wordpress test -d /var/www/html/wp-content/uploads; then
    echo "✅ uploads directory exists"
    
    echo ""
    echo "Current ownership:"
    docker compose exec -T wordpress ls -ld /var/www/html/wp-content/uploads
    docker compose exec -T wordpress ls -la /var/www/html/wp-content/uploads 2>/dev/null | head -n 10 || echo "  (directory empty)"
else
    echo "⚠️  uploads directory does not exist - will be created"
fi
echo ""

echo "Step 2: Fixing uploads directory permissions..."
echo "   Setting ownership to UID:$CURRENT_UID GID:$CURRENT_GID..."

# Fix ownership and permissions of uploads directory
docker compose exec -T wordpress sh -c "
    mkdir -p /var/www/html/wp-content/uploads && \
    chown -R $CURRENT_UID:$CURRENT_GID /var/www/html/wp-content/uploads && \
    chmod -R 755 /var/www/html/wp-content/uploads
" 2>/dev/null

if [ $? -eq 0 ]; then
    echo "✅ Permissions fixed"
else
    echo "❌ Failed to fix permissions"
    echo ""
    echo "Trying alternative method with docker run..."
    
    # Get the volume name
    VOLUME_NAME=$(docker volume ls -q | grep wordpress_uploads || echo "")
    
    if [ -n "$VOLUME_NAME" ]; then
        echo "   Found volume: $VOLUME_NAME"
        echo "   Fixing permissions via temporary container..."
        
        docker run --rm \
            -v ${VOLUME_NAME}:/uploads \
            alpine:latest \
            sh -c "mkdir -p /uploads && chown -R $CURRENT_UID:$CURRENT_GID /uploads && chmod -R 755 /uploads"
        
        echo "✅ Permissions fixed via volume mount"
    else
        echo "❌ Could not find uploads volume"
        exit 1
    fi
fi
echo ""

echo "Step 3: Verifying permissions..."
echo "   Inside container:"
docker compose exec -T wordpress ls -ld /var/www/html/wp-content/uploads
echo ""
echo "   Subdirectories (if any):"
docker compose exec -T wordpress ls -la /var/www/html/wp-content/uploads 2>/dev/null | head -n 10 || echo "   (empty)"
echo ""

echo "Step 4: Testing write permission..."
TEST_FILE="/var/www/html/wp-content/uploads/.test-write-$$"
if docker compose exec -T wordpress touch $TEST_FILE 2>/dev/null; then
    echo "✅ Container CAN write to uploads directory"
    docker compose exec -T wordpress rm $TEST_FILE
else
    echo "❌ Container CANNOT write to uploads directory"
    echo ""
    echo "This might require container restart. Running: docker compose restart wordpress"
    docker compose restart wordpress
    sleep 5
    
    # Test again
    if docker compose exec -T wordpress touch $TEST_FILE 2>/dev/null; then
        echo "✅ After restart: Container CAN write to uploads directory"
        docker compose exec -T wordpress rm $TEST_FILE
    else
        echo "❌ Still cannot write. Please check container logs:"
        echo "   docker compose logs wordpress"
    fi
fi
echo ""

echo "=========================================="
echo "✅ UPLOADS FIX COMPLETE"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Try uploading a file in WordPress"
echo "2. Go to Media → Add New"
echo "3. Upload an image"
echo "4. Should work without errors!"
echo ""
echo "If it still doesn't work:"
echo "- Check: docker compose logs wordpress"
echo "- Verify .env has DOCKER_UID=$CURRENT_UID and DOCKER_GID=$CURRENT_GID"
echo "- Try: docker compose restart"
echo ""
