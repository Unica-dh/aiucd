#!/bin/bash
# Script per risolvere l'errore REST API di WordPress
# "La risposta non è una risposta JSON valida"

set -e

echo "=========================================="
echo "WORDPRESS REST API FIX"
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

echo "Step 1: Checking .htaccess file..."
if [ ! -f wordpress/.htaccess ]; then
    echo "⚠️  .htaccess missing - creating it..."
    
    # Create default WordPress .htaccess
    cat > wordpress/.htaccess << 'EOF'
# BEGIN WordPress
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteRule .* - [E=HTTP_AUTHORIZATION:%{HTTP:Authorization}]
RewriteBase /
RewriteRule ^index\.php$ - [L]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.php [L]
</IfModule>
# END WordPress
EOF
    
    # Fix ownership
    CURRENT_UID=$(id -u)
    CURRENT_GID=$(id -g)
    chown $CURRENT_UID:$CURRENT_GID wordpress/.htaccess
    chmod 644 wordpress/.htaccess
    
    echo "✅ Created .htaccess file"
else
    echo "✅ .htaccess exists"
    echo "   Content:"
    cat wordpress/.htaccess
fi
echo ""

echo "Step 2: Checking Apache mod_rewrite..."
if docker compose exec -T wordpress apache2ctl -M 2>/dev/null | grep -q rewrite; then
    echo "✅ mod_rewrite is enabled"
else
    echo "⚠️  Enabling mod_rewrite..."
    docker compose exec -T wordpress a2enmod rewrite
    docker compose restart wordpress
    sleep 3
    echo "✅ mod_rewrite enabled and Apache restarted"
fi
echo ""

echo "Step 3: Verifying file permissions..."
docker compose exec -T wordpress ls -la /var/www/html/.htaccess 2>/dev/null || echo "⚠️  .htaccess not visible inside container"
echo ""

echo "Step 4: Testing REST API..."
sleep 2
HTTP_CODE=$(curl -s -o /tmp/rest-test.json -w "%{http_code}" http://localhost:7000/wp-json/)
echo "   HTTP Code: $HTTP_CODE"

if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ REST API responding correctly!"
    echo "   Sample response:"
    cat /tmp/rest-test.json | python3 -m json.tool 2>/dev/null | head -n 10 || cat /tmp/rest-test.json | head -n 10
else
    echo "❌ REST API not responding correctly"
    echo "   Response:"
    cat /tmp/rest-test.json | head -n 20
fi
rm -f /tmp/rest-test.json
echo ""

echo "Step 5: Checking for PHP errors..."
ERROR_LOG=$(docker compose exec -T wordpress sh -c 'test -f /var/log/apache2/error.log && tail -n 20 /var/log/apache2/error.log 2>/dev/null | grep -i "error\|warning" || echo ""' 2>/dev/null)
if [ -n "$ERROR_LOG" ]; then
    echo "   Recent errors found:"
    echo "$ERROR_LOG" | head -n 10
else
    echo "   ✅ No recent errors found"
fi
echo ""

echo "=========================================="
echo "MANUAL STEPS REQUIRED:"
echo "=========================================="
echo ""
echo "You MUST do these steps in WordPress admin:"
echo ""
echo "1. Login to WordPress admin panel"
echo "   URL: http://your-domain:7000/wp-admin"
echo ""
echo "2. Go to Settings → Permalinks"
echo "   (Impostazioni → Permalink)"
echo ""
echo "3. Just click 'Save Changes' button"
echo "   (Click 'Salva modifiche')"
echo "   - This will regenerate .htaccess and flush rewrite rules"
echo "   - You don't need to change anything, just save"
echo ""
echo "4. Try publishing content again"
echo ""
echo "If the problem persists after this:"
echo "- Try temporarily switching to Twenty Twenty-Four theme"
echo "- Disable all plugins one by one to find conflicts"
echo "- Check browser console for JavaScript errors"
echo ""
echo "=========================================="
