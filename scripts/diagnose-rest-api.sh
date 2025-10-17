#!/bin/bash
# Script per diagnosticare l'errore REST API di WordPress

echo "=========================================="
echo "WORDPRESS REST API DIAGNOSTIC"
echo "=========================================="
echo ""

echo "1. Checking WordPress container logs (last 50 lines):"
docker compose logs --tail=50 wordpress
echo ""

echo "2. Checking Apache error logs inside container:"
ERROR_LOG=$(docker compose exec -T wordpress sh -c 'test -f /var/log/apache2/error.log && tail -n 30 /var/log/apache2/error.log 2>/dev/null || echo ""' 2>/dev/null)
if [ -n "$ERROR_LOG" ]; then
    echo "$ERROR_LOG" | tail -n 30
else
    echo "   No error log available or empty"
fi
echo ""

echo "3. Testing REST API endpoint:"
HTTP_CODE=$(curl -s -o /tmp/wp-rest-test.txt -w "%{http_code}" http://localhost:7000/wp-json/)
echo "   HTTP Code: $HTTP_CODE"
echo "   Response:"
cat /tmp/wp-rest-test.txt | head -n 20
rm -f /tmp/wp-rest-test.txt
echo ""

echo "4. Checking .htaccess file:"
if [ -f wordpress/.htaccess ]; then
    echo "   .htaccess exists:"
    ls -lah wordpress/.htaccess
    echo "   Content:"
    cat wordpress/.htaccess
else
    echo "   ⚠️  .htaccess NOT FOUND (this might be the problem)"
fi
echo ""

echo "5. Checking wp-config.php for REST API settings:"
grep -i "rest\|json\|rewrite" wordpress/wp-config.php || echo "   No REST API related settings found"
echo ""

echo "6. Testing file write permission:"
TEST_FILE="wordpress/wp-content/.test-write-$$"
if docker compose exec -T wordpress touch /var/www/html/wp-content/.test-write-$$ 2>/dev/null; then
    echo "   ✅ Container CAN write to wp-content/"
    docker compose exec -T wordpress rm /var/www/html/wp-content/.test-write-$$
else
    echo "   ❌ Container CANNOT write to wp-content/"
fi
echo ""

echo "7. Checking permalink structure:"
docker compose exec -T wordpress wp option get permalink_structure 2>/dev/null || echo "   WP-CLI not available"
echo ""

echo "8. PHP error log:"
PHP_LOG=$(docker compose exec -T wordpress sh -c 'test -f /var/log/php-error.log && tail -n 20 /var/log/php-error.log 2>/dev/null || echo ""' 2>/dev/null)
if [ -n "$PHP_LOG" ]; then
    echo "$PHP_LOG"
else
    echo "   No PHP error log found (this is normal)"
fi
echo ""

echo "=========================================="
echo "RECOMMENDATIONS:"
echo "=========================================="
echo ""
echo "Common causes of 'not a valid JSON response':"
echo "1. Missing or corrupted .htaccess file"
echo "2. Permalink structure not configured"
echo "3. PHP errors breaking JSON output"
echo "4. Apache mod_rewrite not enabled"
echo "5. Theme/Plugin conflict"
echo ""
echo "Try these fixes:"
echo "1. Reset permalinks: Login to WordPress → Settings → Permalinks → Save"
echo "2. Check for PHP errors in the logs above"
echo "3. Temporarily switch to default theme"
echo "4. Disable all plugins temporarily"
echo ""
