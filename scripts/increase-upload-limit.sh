#!/bin/bash
# Increase WordPress upload limit to 100MB

set -e

echo "=========================================="
echo "INCREASE WORDPRESS UPLOAD LIMIT TO 100MB"
echo "=========================================="
echo ""

if [ ! -f "docker-compose.yml" ]; then
    echo "❌ Error: Run this from the project root directory"
    exit 1
fi

echo "Step 1: Verifying PHP configuration file..."
if [ ! -f "php-config/uploads.ini" ]; then
    echo "❌ php-config/uploads.ini not found"
    exit 1
fi
echo "✅ PHP configuration file exists"
echo ""

echo "Step 2: Restarting WordPress container with new configuration..."
docker compose restart wordpress
sleep 3
echo "✅ Container restarted"
echo ""

echo "Step 3: Verifying PHP settings..."
echo ""
echo "Current PHP upload settings:"
docker compose exec -T wordpress php -i | grep -E "upload_max_filesize|post_max_size|memory_limit" | head -6
echo ""

echo "Step 4: Adding WordPress filter for upload limit..."
WP_CONFIG_PATH="./wordpress/wp-config.php"

# Check if the define already exists
if grep -q "WP_MEMORY_LIMIT" "$WP_CONFIG_PATH"; then
    echo "✅ WP_MEMORY_LIMIT already defined"
else
    echo "   Adding WP_MEMORY_LIMIT to wp-config.php..."
    
    # Find the line with "That's all, stop editing!" and add before it
    if grep -q "stop editing" "$WP_CONFIG_PATH"; then
        sed -i "/stop editing/i\
// Increase WordPress memory limit\n\
define('WP_MEMORY_LIMIT', '256M');\n\
define('WP_MAX_MEMORY_LIMIT', '256M');\n" "$WP_CONFIG_PATH"
        echo "✅ Added WP_MEMORY_LIMIT"
    else
        echo "⚠️  Could not find insertion point, please add manually:"
        echo "   define('WP_MEMORY_LIMIT', '256M');"
    fi
fi
echo ""

echo "Step 5: Creating .htaccess rules for upload limit..."
HTACCESS_PATH="./wordpress/.htaccess"

if [ -f "$HTACCESS_PATH" ]; then
    # Check if PHP upload settings already exist
    if grep -q "php_value upload_max_filesize" "$HTACCESS_PATH"; then
        echo "✅ Upload settings already in .htaccess"
    else
        echo "   Adding upload settings to .htaccess..."
        
        # Add PHP settings at the beginning of the file
        {
            echo "# PHP Upload Configuration"
            echo "php_value upload_max_filesize 100M"
            echo "php_value post_max_size 100M"
            echo "php_value memory_limit 256M"
            echo "php_value max_execution_time 300"
            echo "php_value max_input_time 300"
            echo ""
            cat "$HTACCESS_PATH"
        } > "$HTACCESS_PATH.tmp"
        
        mv "$HTACCESS_PATH.tmp" "$HTACCESS_PATH"
        echo "✅ Added upload settings to .htaccess"
    fi
else
    echo "⚠️  .htaccess not found, creating with upload settings..."
    cat > "$HTACCESS_PATH" << 'EOF'
# PHP Upload Configuration
php_value upload_max_filesize 100M
php_value post_max_size 100M
php_value memory_limit 256M
php_value max_execution_time 300
php_value max_input_time 300

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
    echo "✅ Created .htaccess with upload settings"
fi
echo ""

# Fix ownership
CURRENT_UID=$(id -u)
CURRENT_GID=$(id -g)
chown $CURRENT_UID:$CURRENT_GID "$HTACCESS_PATH" 2>/dev/null || true
chown $CURRENT_UID:$CURRENT_GID "$WP_CONFIG_PATH" 2>/dev/null || true

echo "Step 6: Final verification..."
echo ""
echo "WordPress upload limit check:"
docker compose exec -T wordpress php -r "echo 'upload_max_filesize: ' . ini_get('upload_max_filesize') . \"\n\";"
docker compose exec -T wordpress php -r "echo 'post_max_size: ' . ini_get('post_max_size') . \"\n\";"
docker compose exec -T wordpress php -r "echo 'memory_limit: ' . ini_get('memory_limit') . \"\n\";"
echo ""

echo "=========================================="
echo "✅ UPLOAD LIMIT INCREASED TO 100MB"
echo "=========================================="
echo ""
echo "Changes made:"
echo "1. PHP: upload_max_filesize = 100M"
echo "2. PHP: post_max_size = 100M"
echo "3. PHP: memory_limit = 256M"
echo "4. WordPress: WP_MEMORY_LIMIT = 256M"
echo "5. Apache: .htaccess updated"
echo ""
echo "Next steps:"
echo "1. Go to WordPress Media Library"
echo "2. Try uploading files up to 100MB"
echo "3. Should work without errors!"
echo ""
echo "Note: Browser timeout may occur for very large files"
echo "Consider using FTP for files larger than 50MB"
echo ""
