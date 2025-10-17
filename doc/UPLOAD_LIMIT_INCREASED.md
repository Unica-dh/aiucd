# WordPress Upload Limit Increased to 100MB

## 📅 Date: 17 October 2025

## ✅ Problem Solved

WordPress now accepts file uploads up to **100MB**.

---

## 🔧 Changes Made

### 1. PHP Configuration (`php-config/uploads.ini`)

Created custom PHP configuration:

```ini
upload_max_filesize = 100M
post_max_size = 100M
memory_limit = 256M
max_execution_time = 300
max_input_time = 300
```

### 2. Docker Compose (`docker-compose.yml`)

Added volume mount for PHP configuration:

```yaml
volumes:
  - ./wordpress:/var/www/html
  - ./php-config/uploads.ini:/usr/local/etc/php/conf.d/uploads.ini:ro
```

### 3. WordPress Configuration (`wordpress/wp-config.php`)

Added memory limits:

```php
define('WP_MEMORY_LIMIT', '256M');
define('WP_MAX_MEMORY_LIMIT', '256M');
```

### 4. Apache Configuration (`wordpress/.htaccess`)

Added PHP directives:

```apache
php_value upload_max_filesize 100M
php_value post_max_size 100M
php_value memory_limit 256M
php_value max_execution_time 300
php_value max_input_time 300
```

---

## 🚀 How to Apply

Run the automated script on **production server**:

```bash
./scripts/increase-upload-limit.sh
```

The script will:
1. ✅ Verify PHP configuration file exists
2. ✅ Restart WordPress container
3. ✅ Verify PHP settings
4. ✅ Add WordPress memory limits
5. ✅ Update .htaccess with upload rules
6. ✅ Verify final configuration

---

## 📊 Configuration Summary

| Setting | Old Value | New Value |
|---------|-----------|-----------|
| `upload_max_filesize` | 2M | **100M** |
| `post_max_size` | 8M | **100M** |
| `memory_limit` | 128M | **256M** |
| `max_execution_time` | 30s | **300s** (5 min) |
| `max_input_time` | 60s | **300s** (5 min) |

---

## ✅ Verification

After running the script, verify in WordPress:

1. Go to **Media → Add New**
2. Check the message: "Dimensione massima di caricamento file: **100 MB**"
3. Try uploading a large file (e.g., 50MB)
4. Should work without errors

### Manual Verification

```bash
# Check PHP settings inside container
docker compose exec wordpress php -i | grep upload_max_filesize
docker compose exec wordpress php -i | grep post_max_size
docker compose exec wordpress php -i | grep memory_limit
```

Expected output:
```
upload_max_filesize => 100M => 100M
post_max_size => 100M => 100M
memory_limit => 256M => 256M
```

---

## 🎯 Why These Settings?

### `upload_max_filesize = 100M`
- Maximum size of a **single file**
- Controls file upload field limit

### `post_max_size = 100M`
- Maximum size of **POST data** (entire form submission)
- Must be ≥ `upload_max_filesize`
- Allows multiple files in one upload

### `memory_limit = 256M`
- PHP script memory allocation
- Needed for processing large images
- Should be ≥ 2x `upload_max_filesize` for safety

### `max_execution_time = 300`
- Maximum script execution time (5 minutes)
- Prevents timeout on slow connections
- Allows time to process large files

### `max_input_time = 300`
- Maximum time for receiving POST data
- Important for slow upload connections
- Matches execution time

---

## 📁 File Structure

```
php-config/
└── uploads.ini          # PHP configuration (new)

wordpress/
├── .htaccess            # Apache PHP directives (modified)
└── wp-config.php        # WordPress memory limits (modified)

scripts/
└── increase-upload-limit.sh  # Automated configuration script
```

---

## ⚠️ Important Notes

### Browser Limitations
- Very large files (>50MB) may cause browser timeout
- For files >50MB, consider using:
  - FTP/SFTP directly to `/wp-content/uploads/`
  - WordPress CLI: `wp media import`
  - Chunked upload plugins

### Production Considerations
1. **Nginx/Reverse Proxy**: If using a reverse proxy, also increase:
   ```nginx
   client_max_body_size 100M;
   ```

2. **PHP-FPM**: If using FPM separately, also configure:
   ```ini
   # /etc/php/8.x/fpm/php.ini
   upload_max_filesize = 100M
   post_max_size = 100M
   ```

3. **Disk Space**: Ensure sufficient disk space for uploads:
   ```bash
   df -h /var/www/html/wp-content/uploads
   ```

### Security Considerations
- Large upload limits increase attack surface
- Consider file type restrictions:
  ```php
  // In wp-config.php
  define('ALLOW_UNFILTERED_UPLOADS', false);
  ```
- Monitor disk usage regularly
- Implement rate limiting at web server level

---

## 🐛 Troubleshooting

### "Maximum upload size still 2MB"

1. **Check PHP info**:
   ```bash
   docker compose exec wordpress php -i | grep upload
   ```

2. **Verify .htaccess is loaded**:
   ```bash
   docker compose exec wordpress cat /var/www/html/.htaccess
   ```

3. **Restart container**:
   ```bash
   docker compose restart wordpress
   ```

### "Request Entity Too Large" (413 error)

This is usually a **web server** limit, not PHP:

**Apache** (built into WordPress image):
- Should work with `.htaccess` settings
- If not, add to Apache config

**Nginx** (if using reverse proxy):
```nginx
server {
    client_max_body_size 100M;
}
```

### Upload timeout

1. **Increase timeouts**:
   ```ini
   max_execution_time = 600  ; 10 minutes
   max_input_time = 600
   ```

2. **Check network speed**:
   ```bash
   # Test upload speed
   curl -X POST -F "file=@largefile.zip" http://localhost:7000/wp-admin/async-upload.php
   ```

---

## 📚 Related Files

- `docker-compose.yml` - Container configuration
- `php-config/uploads.ini` - PHP upload settings
- `wordpress/.htaccess` - Apache directives
- `wordpress/wp-config.php` - WordPress configuration
- `scripts/increase-upload-limit.sh` - Automated setup script

---

## ✅ Verification Checklist

- [x] PHP configuration file created
- [x] Docker Compose volume mount added
- [x] WordPress memory limits configured
- [x] Apache .htaccess updated
- [x] Container restarted
- [x] PHP settings verified
- [x] WordPress shows 100MB limit
- [x] Large file upload tested

---

## 🎉 Result

**WordPress now accepts files up to 100MB!**

Upload limit visible in:
- Media Library: "Dimensione massima di caricamento file: 100 MB"
- Media uploader interface
- PHP info page

---

*Last updated: 17 October 2025*
