# 🚀 Setup Produzione WordPress

## Configurazione URL Sito

Per configurare l'URL del sito WordPress in produzione, modifica il file `.env` sul server di produzione.

### Passo 1: Accedi al server

```bash
ssh dhpasteur@SERVER_IP
cd ~/actions-runner/_work/aiucd/aiucd
```

### Passo 2: Modifica il file .env

```bash
nano .env
```

### Passo 3: Aggiungi la configurazione URL

Aggiungi o modifica la variabile `WORDPRESS_CONFIG_EXTRA` per includere le definizioni di URL:

```bash
# WordPress Site URL Configuration
WORDPRESS_CONFIG_EXTRA=define('WP_HOME','https://www.aiucd2026.unica.it');define('WP_SITEURL','https://www.aiucd2026.unica.it');
```

**Nota**: Le definizioni devono essere su una sola riga, senza spazi dopo le virgole.

### Passo 4: Riavvia i container

```bash
docker compose down
docker compose up -d
```

### Passo 5: Verifica

```bash
curl -I http://localhost:7000
# Dovresti vedere un redirect verso https://www.aiucd2026.unica.it
```

## Configurazione Completa .env per Produzione

Esempio di `.env` configurato per produzione:

```bash
# WordPress Database Configuration
WORDPRESS_DB_NAME=wordpress
WORDPRESS_DB_USER=wpuser
WORDPRESS_DB_PASSWORD=STRONG_PASSWORD_HERE_CHANGE_ME

# MySQL Root Password
MYSQL_ROOT_PASSWORD=STRONG_ROOT_PASSWORD_HERE_CHANGE_ME

# WordPress Security Keys
# Generate new keys at: https://api.wordpress.org/secret-key/1.1/salt/
WORDPRESS_AUTH_KEY=GENERATE_UNIQUE_KEY_HERE
WORDPRESS_SECURE_AUTH_KEY=GENERATE_UNIQUE_KEY_HERE
WORDPRESS_LOGGED_IN_KEY=GENERATE_UNIQUE_KEY_HERE
WORDPRESS_NONCE_KEY=GENERATE_UNIQUE_KEY_HERE
WORDPRESS_AUTH_SALT=GENERATE_UNIQUE_SALT_HERE
WORDPRESS_SECURE_AUTH_SALT=GENERATE_UNIQUE_SALT_HERE
WORDPRESS_LOGGED_IN_SALT=GENERATE_UNIQUE_SALT_HERE
WORDPRESS_NONCE_SALT=GENERATE_UNIQUE_SALT_HERE

# Optional: Environment identifier
ENVIRONMENT=production

# WordPress Site URL Configuration
WORDPRESS_CONFIG_EXTRA=define('WP_HOME','https://www.aiucd2026.unica.it');define('WP_SITEURL','https://www.aiucd2026.unica.it');
```

## Aggiornamento Database (se necessario)

Se WordPress è già installato e hai bisogno di cambiare l'URL nel database:

```bash
docker compose exec db mysql -uwpuser -pYOUR_PASSWORD wordpress -e "UPDATE wp_options SET option_value = 'https://www.aiucd2026.unica.it' WHERE option_name IN ('siteurl', 'home');"
```

**Nota**: Con `WP_HOME` e `WP_SITEURL` definiti nel `wp-config.php` (tramite `WORDPRESS_CONFIG_EXTRA`), questi valori hanno la precedenza sul database e non possono essere modificati dal pannello admin di WordPress.

## Verifica Configurazione SSL

Assicurati che il reverse proxy (Nginx/Apache) davanti a Docker gestisca correttamente l'SSL e passi gli header corretti:

```nginx
# Nginx example
location / {
    proxy_pass http://localhost:7000;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}
```

Questo è necessario perché WordPress rileva HTTPS tramite l'header `X-Forwarded-Proto` (già configurato in `wp-config.php`).
