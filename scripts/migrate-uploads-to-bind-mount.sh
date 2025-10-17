#!/bin/bash
# Migrazione da named volume a bind mount per uploads

set -e

echo "=========================================="
echo "WORDPRESS UPLOADS - MIGRATE TO BIND MOUNT"
echo "=========================================="
echo ""

if [ ! -f "docker-compose.yml" ]; then
    echo "❌ Error: Run this from the project root directory"
    exit 1
fi

echo "⚠️  IMPORTANT: This will migrate uploads from named volume to bind mount"
echo ""
read -p "Do you want to continue? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
fi
echo ""

CURRENT_UID=$(id -u)
CURRENT_GID=$(id -g)

echo "Step 1: Backup existing uploads from named volume..."
mkdir -p ./uploads-backup

# Try to copy from running container first
if docker compose ps | grep -q "wordpress.*Up"; then
    echo "   Copying from running container..."
    docker compose exec -T wordpress tar czf /tmp/uploads-backup.tar.gz -C /var/www/html/wp-content uploads 2>/dev/null || true
    docker compose cp wordpress:/tmp/uploads-backup.tar.gz ./uploads-backup/uploads-backup.tar.gz 2>/dev/null || true
fi

# Also try to access volume directly
VOLUME_NAME=$(docker volume ls -q | grep wordpress_uploads || echo "")
if [ -n "$VOLUME_NAME" ]; then
    echo "   Backing up from volume: $VOLUME_NAME..."
    docker run --rm \
        -v ${VOLUME_NAME}:/source \
        -v "$(pwd)/uploads-backup:/backup" \
        alpine:latest \
        sh -c "tar czf /backup/uploads-volume.tar.gz -C /source . 2>/dev/null || true"
    
    if [ -f ./uploads-backup/uploads-volume.tar.gz ]; then
        echo "✅ Backup saved to: ./uploads-backup/uploads-volume.tar.gz"
    fi
fi
echo ""

echo "Step 2: Stopping containers..."
docker compose down
echo "✅ Containers stopped"
echo ""

echo "Step 3: Creating uploads directory in bind mount..."
mkdir -p ./wordpress/wp-content/uploads
chown $CURRENT_UID:$CURRENT_GID ./wordpress/wp-content/uploads
chmod 755 ./wordpress/wp-content/uploads
echo "✅ Directory created"
echo ""

echo "Step 4: Restoring uploads from backup (if exists)..."
if [ -f ./uploads-backup/uploads-volume.tar.gz ]; then
    echo "   Extracting backup..."
    tar xzf ./uploads-backup/uploads-volume.tar.gz -C ./wordpress/wp-content/uploads 2>/dev/null || true
    
    # Fix ownership
    chown -R $CURRENT_UID:$CURRENT_GID ./wordpress/wp-content/uploads
    chmod -R 755 ./wordpress/wp-content/uploads
    
    FILE_COUNT=$(find ./wordpress/wp-content/uploads -type f | wc -l)
    echo "✅ Restored $FILE_COUNT files"
elif [ -f ./uploads-backup/uploads-backup.tar.gz ]; then
    echo "   Extracting from container backup..."
    tar xzf ./uploads-backup/uploads-backup.tar.gz -C ./wordpress/wp-content/ 2>/dev/null || true
    
    chown -R $CURRENT_UID:$CURRENT_GID ./wordpress/wp-content/uploads
    chmod -R 755 ./wordpress/wp-content/uploads
    
    FILE_COUNT=$(find ./wordpress/wp-content/uploads -type f | wc -l)
    echo "✅ Restored $FILE_COUNT files"
else
    echo "   No backup found (this is OK for new installations)"
fi
echo ""

echo "Step 5: Removing old named volume..."
if [ -n "$VOLUME_NAME" ]; then
    docker volume rm $VOLUME_NAME 2>/dev/null && echo "✅ Volume removed" || echo "⚠️  Volume not found or already removed"
else
    echo "   No volume to remove"
fi
echo ""

echo "Step 6: Starting containers with new configuration..."
docker compose up -d
sleep 5
echo "✅ Containers started"
echo ""

echo "Step 7: Verifying configuration..."
docker compose ps
echo ""

echo "Step 8: Testing uploads directory..."
docker compose exec -T wordpress ls -ld /var/www/html/wp-content/uploads
echo ""

if docker compose exec -T wordpress test -w /var/www/html/wp-content/uploads; then
    echo "✅ uploads directory is WRITABLE by container"
else
    echo "❌ uploads directory is NOT writable - trying to fix..."
    docker compose exec -T wordpress chown -R $CURRENT_UID:$CURRENT_GID /var/www/html/wp-content/uploads
    docker compose exec -T wordpress chmod -R 755 /var/www/html/wp-content/uploads
fi
echo ""

echo "=========================================="
echo "✅ MIGRATION COMPLETE"
echo "=========================================="
echo ""
echo "Changes made:"
echo "1. Named volume removed"
echo "2. Uploads now in: ./wordpress/wp-content/uploads"
echo "3. Permissions set to UID:$CURRENT_UID GID:$CURRENT_GID"
echo "4. All existing uploads preserved"
echo ""
echo "Next steps:"
echo "1. Try uploading a file in WordPress"
echo "2. Should work without errors!"
echo ""
echo "Backup location: ./uploads-backup/"
echo "You can delete this after confirming uploads work."
echo ""
