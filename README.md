# WordPress Docker Compose Setup

> 🚀 **Ambiente WordPress professionale con Docker Compose** - Deploy automatico, permessi corretti, upload fino a 100MB

## 📋 Requisiti del Progetto

### Obiettivo

Realizzare un sito WordPress completo utilizzando Docker Compose per lo sviluppo e la produzione, con configurazione semplificata e ottimizzata.

### ✅ Stato del Progetto

- ✅ **Deploy automatico** via GitHub Actions
- ✅ **Permessi corretti** con user mapping
- ✅ **REST API funzionanti** con .htaccess configurato
- ✅ **Upload file fino a 100MB**
- ✅ **Pubblicazione contenuti** senza errori FTP
- ✅ **Scripts di manutenzione** per diagnostica e fix

### Specifiche Tecniche

#### 🔧 Configurazione di Base

**Porta di esposizione**: `7000` (HTTP)
**Database**: MariaDB 10.11.5
**Web Server**: Apache (integrato nel container WordPress)
**PHP**: Versione stabile con configurazione ottimizzata (upload 100MB)
**Gestione SSL**: Non necessaria (gestita lato server)
**Upload Limit**: 100MB per file

#### 🐳 Servizi Docker

1. **WordPress** (`wordpress:6.8.3-apache`)
   - Container principale con WordPress + Apache + PHP
   - Esposto sulla porta 7000
   - User mapping per permessi corretti (UID/GID host)
   - Configurazione PHP: upload 100MB, memory 256MB
   - Volumi persistenti per files e uploads (bind mount)

2. **Database** (`mariadb:10.11.5`)
   - Database MariaDB per WordPress
   - Volumi persistenti per i dati (named volume)
   - Rete interna (non esposta esternamente)

3. **phpMyAdmin** (`phpmyadmin:5.2.1`)
   - Interfaccia web per gestione database
   - Esposto sulla porta 8080 per amministrazione

#### 📁 Struttura Directory

```text
/home/ale/docker/aiucd/
├── README.md                   # Questa guida
├── docker-compose.yml          # Configurazione Docker completa
├── .env                        # Variabili d'ambiente (non versionato)
├── .env.example               # Template variabili d'ambiente
├── .github/
│   └── workflows/
│       └── deploy.yml         # Deploy automatico CI/CD
├── wordpress/                 # Volume dati WordPress (bind mount)
│   ├── .htaccess             # Configurazione Apache (rewrite rules)
│   ├── wp-config.php         # Configurazione WordPress
│   └── wp-content/
│       ├── uploads/          # Upload files (fino a 100MB)
│       ├── themes/           # Temi WordPress
│       └── plugins/          # Plugin WordPress
├── php-config/
│   └── uploads.ini           # Configurazione PHP (upload 100MB)
├── scripts/                  # Scripts di utility
│   ├── diagnose-permissions.sh      # Diagnostica permessi
│   ├── fix-permissions.sh           # Fix automatico permessi
│   ├── diagnose-rest-api.sh         # Test REST API
│   ├── fix-rest-api.sh              # Fix REST API (.htaccess)
│   ├── increase-upload-limit.sh     # Aumenta limite upload
│   ├── migrate-uploads-to-bind-mount.sh  # Migrazione uploads
│   └── README.md                    # Documentazione scripts
└── doc/                      # Documentazione tecnica
    ├── FIX_SUMMARY.md              # Riepilogo fix applicati
    ├── PROBLEMA_RISOLTO.md         # Problemi risolti
    ├── QUICK_FIX_REST_API.md       # Quick fix REST API
    ├── UPLOAD_LIMIT_INCREASED.md   # Documentazione upload limit
    └── ...                         # Altri documenti tecnici
```

#### 🔐 Configurazione Sicurezza

- **Credenziali database**: Gestite tramite file `.env`
- **WordPress secrets**: Chiavi di sicurezza generate automaticamente
- **Accesso database**: Solo rete interna Docker
- **File sensibili**: `.env` escluso dal versioning
- **User mapping**: Container gira con UID/GID utente host (no root)
- **Permessi file**: 644 per file, 755 per directory (no 777)
- **Upload security**: Limite 100MB, tipi file controllati da WordPress

#### 🌐 Accesso Applicazione

- **WordPress**: `http://localhost:7000`
- **phpMyAdmin**: `http://localhost:8080` (se abilitato)
- **Database**: Accessibile solo internamente tra container

## 📋 Requisiti Sistema

### Software Richiesti

- **Docker**: versione 20.10+
- **Docker Compose**: versione 2.0+
- **Sistema Operativo**: Linux (testato), macOS, Windows con WSL2

### Risorse Hardware Minime

- **RAM**: 1GB libera
- **Storage**: 2GB liberi per volumi Docker
- **CPU**: 1 core (2+ raccomandati)

## 🚀 Funzionalità

### Core Features Implementate

- ✅ **WordPress 6.8.3** con Apache
- ✅ **Database MariaDB 10.11.5** con persistenza
- ✅ **Deploy automatico** via GitHub Actions
- ✅ **User mapping** per permessi corretti
- ✅ **REST API** configurate e funzionanti
- ✅ **Upload fino a 100MB** per file
- ✅ **phpMyAdmin 5.2.1** per gestione database
- ✅ **Backup automatici** database pre-deploy
- ✅ **Health checks** nel workflow CI/CD
- ✅ **Configurazione via environment** (.env)
- ✅ **Rete isolata** per sicurezza
- ✅ **Scripts di diagnostica** e fix automatici

### Configurazioni Ottimizzate

- 📦 **PHP Upload**: 100MB max file size
- 💾 **PHP Memory**: 256MB per WordPress
- ⏱️ **Execution Time**: 300 secondi (5 minuti)
- 🔄 **mod_rewrite**: Abilitato per permalink
- 🔐 **FS_METHOD**: Direct (no FTP)

### Features Escluse

- ❌ **Gestione SSL/HTTPS** (gestita lato server)
- ❌ **Reverse proxy Nginx** (non necessario)
- ❌ **Load balancing** (single instance)
- ❌ **Redis cache** (può essere aggiunto se necessario)

## 🎯 Casi d'Uso

### Sviluppo Locale

- Ambiente WordPress completo per sviluppo temi/plugin
- Database isolato per test
- Reset rapido dell'ambiente

### Staging/Produzione

- Deploy rapido su server
- Configurazione consistente tra ambienti
- Backup e restore semplificati

### Prototipazione

- Setup veloce per demo e test
- Configurazione minimal ma completa
- Facile personalizzazione

## 🛠️ Troubleshooting

### Problema: Errore "La risposta non è una risposta JSON valida"

**Soluzione rapida**:
```bash
./scripts/fix-rest-api.sh
```

Poi vai in WordPress Admin → Impostazioni → Permalink → Salva modifiche.

**Dettagli**: Vedi `doc/QUICK_FIX_REST_API.md`

---

### Problema: Upload file fallisce

**Soluzione**:
```bash
./scripts/fix-permissions.sh
```

Se il limite di 2MB è troppo basso:
```bash
./scripts/increase-upload-limit.sh
```

---

### Problema: Permission denied durante deploy

**Causa**: UID/GID non configurato nel `.env`

**Soluzione**:
```bash
# Sul server di produzione
echo "DOCKER_UID=$(id -u)" >> .env
echo "DOCKER_GID=$(id -g)" >> .env
docker compose down
docker compose up -d
```

---

### Problema: Container non si avvia

```bash
# Controlla i log
docker compose logs wordpress
docker compose logs db

# Verifica configurazione
docker compose config

# Riavvia pulito
docker compose down
docker compose up -d
```

---

### Problema: Database connection error

```bash
# Verifica che il database sia pronto
docker compose exec db mysql -u wordpress -p

# Controlla variabili ambiente
docker compose exec wordpress env | grep WORDPRESS_DB

# Ricrea database
docker compose down
docker compose up -d db
# Attendi 10 secondi
docker compose up -d wordpress
```

---

## 📚 Documentazione Dettagliata

La directory `doc/` contiene guide approfondite:

- **`FIX_SUMMARY.md`** - Riepilogo di tutti i fix applicati
- **`PROBLEMA_RISOLTO.md`** - Storico problemi risolti
- **`QUICK_FIX_REST_API.md`** - Quick reference REST API
- **`UPLOAD_LIMIT_INCREASED.md`** - Come funziona l'upload 100MB
- **`PERMISSION_ANALYSIS.md`** - Analisi tecnica permessi
- **`PRODUCTION_FIX_GUIDE.md`** - Guida produzione
- **`GITHUB_ACTIONS_SETUP.md`** - Setup CI/CD
- **`QUICKSTART_GITHUB_ACTIONS.md`** - Quick start deploy

---

## 🏗️ Architettura del Sistema

### User Mapping Strategy

Il container WordPress gira con lo stesso UID/GID dell'utente host:

```yaml
# docker-compose.yml
services:
  wordpress:
    user: "${DOCKER_UID:-1000}:${DOCKER_GID:-1000}"
    environment:
      APACHE_RUN_USER: "#${DOCKER_UID:-1000}"
      APACHE_RUN_GROUP: "#${DOCKER_GID:-1000}"
```

**Benefici**:
- ✅ File creati dal container hanno ownership corretta
- ✅ Git può modificare file senza permission denied
- ✅ WordPress può scrivere file senza FTP
- ✅ Deploy GitHub Actions funziona senza sudo
- ✅ Nessun bisogno di permessi 777 pericolosi

### Volume Strategy

**Bind Mount** per codice versionabile:

```yaml
volumes:
  - ./wordpress:/var/www/html
```

**Named Volume** solo per database:

```yaml
volumes:
  - db_data:/var/lib/mysql
```

**Configurazione PHP** via read-only mount:

```yaml
volumes:
  - ./php-config/uploads.ini:/usr/local/etc/php/conf.d/uploads.ini:ro
```

### Network Isolation

```yaml
networks:
  aiucd_network:
    driver: bridge
```

- Database accessibile solo da container WordPress
- Nessuna porta database esposta all'host
- phpMyAdmin può accedere al database via network interno

## 🎓 Best Practices Implementate

### Sicurezza

- ✅ Container non-root (user mapping)
- ✅ Database non esposto esternamente
- ✅ Secrets in file .env (non versionato)
- ✅ Permessi file minimali (no 777)
- ✅ Configurazione PHP hardened

### Performance

- ✅ PHP memory limit ottimizzato (256MB)
- ✅ Execution time adeguato (300s)
- ✅ Upload ottimizzato (100MB)
- ✅ Volumi persistenti per evitare rebuild

### Manutenibilità

- ✅ Scripts automatizzati per fix comuni
- ✅ Documentazione completa
- ✅ Logs accessibili
- ✅ Health checks nel CI/CD
- ✅ Backup automatici

### DevOps

- ✅ Infrastructure as Code (docker-compose.yml)
- ✅ CI/CD con GitHub Actions
- ✅ Deploy automatico
- ✅ Rollback capabilities (via Git)
- ✅ Environment parity (dev = prod)

---

## 🎯 Configurazione Completa .env

Esempio di file `.env` completo per produzione:

```bash
# Docker User Mapping (IMPORTANTE!)
DOCKER_UID=1001
DOCKER_GID=1001

# WordPress Database Configuration
WORDPRESS_DB_NAME=wordpress
WORDPRESS_DB_USER=wpuser
WORDPRESS_DB_PASSWORD=change_this_secure_password

# MySQL Root Password
MYSQL_ROOT_PASSWORD=change_this_root_password

# WordPress URL (opzionale, default: http://localhost:7000)
WORDPRESS_URL=https://tuo-dominio.it

# WordPress Security Keys (genera qui: https://api.wordpress.org/secret-key/1.1/salt/)
WORDPRESS_AUTH_KEY='genera-chiave-sicura-qui'
WORDPRESS_SECURE_AUTH_KEY='genera-chiave-sicura-qui'
WORDPRESS_LOGGED_IN_KEY='genera-chiave-sicura-qui'
WORDPRESS_NONCE_KEY='genera-chiave-sicura-qui'
WORDPRESS_AUTH_SALT='genera-chiave-sicura-qui'
WORDPRESS_SECURE_AUTH_SALT='genera-chiave-sicura-qui'
WORDPRESS_LOGGED_IN_SALT='genera-chiave-sicura-qui'
WORDPRESS_NONCE_SALT='genera-chiave-sicura-qui'

# WordPress Extra Configuration
WORDPRESS_CONFIG_EXTRA="
define('WP_DEBUG', false);
define('WP_DEBUG_LOG', false);
define('WP_DEBUG_DISPLAY', false);
define('DISALLOW_FILE_EDIT', true);
define('FS_METHOD', 'direct');
define('WP_MEMORY_LIMIT', '256M');
define('WP_MAX_MEMORY_LIMIT', '256M');
"
```

---

## 📊 Checklist Pre-Produzione

Prima di andare in produzione, verifica:

- [ ] File `.env` configurato con valori sicuri
- [ ] UID/GID configurato correttamente (`DOCKER_UID`, `DOCKER_GID`)
- [ ] Chiavi WordPress generate e inserite
- [ ] Password database sicure (no default)
- [ ] GitHub Secrets configurati per deploy automatico
- [ ] SSL configurato sul server (a monte di Docker)
- [ ] Backup automatici attivi
- [ ] Monitoring configurato (opzionale)
- [ ] Test deploy funzionante
- [ ] Test REST API: `curl http://tuo-dominio/wp-json/`
- [ ] Test upload file in WordPress
- [ ] Permalink salvati (Impostazioni → Permalink)

---

## 🚀 Prossimi Sviluppi

Possibili miglioramenti futuri:

- 🔄 **Redis cache** per migliorare performance
- 📧 **Email SMTP** configurazione
- 🔍 **Elasticsearch** per search avanzata
- 📈 **Monitoring** con Prometheus/Grafana
- 🔐 **2FA** per login WordPress
- 🌍 **CDN integration** per assets statici
- 🤖 **Automated testing** con Playwright
- 📱 **Mobile app** integrazione

---

## 🤝 Contribuire

Per contribuire al progetto:

1. Fork del repository
2. Crea feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit modifiche (`git commit -m 'Add some AmazingFeature'`)
4. Push al branch (`git push origin feature/AmazingFeature`)
5. Apri Pull Request

---

## 📝 Changelog

### v1.0.0 - 17 Ottobre 2025

**Features**:

- ✅ Setup completo WordPress + MariaDB + phpMyAdmin
- ✅ Deploy automatico via GitHub Actions
- ✅ User mapping per permessi corretti
- ✅ REST API configurate e funzionanti
- ✅ Upload file fino a 100MB
- ✅ Scripts di diagnostica e fix
- ✅ Documentazione completa

**Bug Fixes**:

- 🐛 Fix permission denied durante deploy
- 🐛 Fix REST API "not valid JSON response"
- 🐛 Fix upload file directory creation error
- 🐛 Fix GitHub Actions workflow syntax error

---

## 📞 Supporto

Per problemi o domande:

1. Consulta la documentazione in `doc/`
2. Esegui script di diagnostica appropriato
3. Controlla i logs: `docker compose logs`
4. Cerca nel README nella sezione Troubleshooting

---

## 📄 Licenza

Questo progetto è distribuito con licenza MIT. Vedi file `LICENSE` per dettagli.

---

## 🙏 Ringraziamenti

- WordPress Team per l'eccellente CMS
- Docker Team per la containerizzazione
- MariaDB Team per il database performante
- Community open source per supporto e feedback

---

**🎉 Il tuo ambiente WordPress Docker è pronto per la produzione!**

---

## 📞 Quick Start

### Prima Installazione

```bash
# 1. Clone o naviga nella directory
cd /home/ale/docker/aiucd

# 2. Copia e configura le variabili d'ambiente
cp .env.example .env

# 3. IMPORTANTE: Configura UID/GID per permessi corretti
echo "DOCKER_UID=$(id -u)" >> .env
echo "DOCKER_GID=$(id -g)" >> .env

# 4. Genera chiavi di sicurezza WordPress
# Visita: https://api.wordpress.org/secret-key/1.1/salt/
# Copia le chiavi generate nel file .env

# 5. Configura credenziali database nel .env:
nano .env  # Modifica WORDPRESS_DB_PASSWORD, MYSQL_ROOT_PASSWORD

# 6. Avvia i servizi
docker compose up -d

# 7. Attendi qualche secondo e verifica
docker compose ps

# 8. Accedi a WordPress
# http://localhost:7000
```

### Primo Accesso WordPress

1. Vai su `http://localhost:7000`
2. Completa l'installazione guidata
3. **Importante**: Vai in `Impostazioni → Permalink` e clicca **Salva modifiche** (Questo genera il file .htaccess per REST API)
4. Tutto pronto! 🎉

### Deploy su Produzione con GitHub Actions

Il progetto include deploy automatico:

```bash
# 1. Configura .env sul server di produzione (vedi sopra)

# 2. Configura GitHub Secrets nel repository:
# - SERVER_HOST: IP o hostname del server
# - SERVER_USER: username SSH
# - SERVER_SSH_KEY: chiave privata SSH
# - SERVER_PATH: path al progetto sul server

# 3. Commit e push per deployare
git add .
git commit -m "Deploy to production"
git push origin main

# 4. Il workflow GitHub Actions farà automaticamente:
# - Backup database
# - Deploy nuovo codice
# - Riavvio container
# - Health check
```

## 🔧 Comandi Utili

### Gestione Container

```bash
# Visualizza status servizi
docker compose ps

# Visualizza logs (tutti i servizi)
docker compose logs -f

# Visualizza logs WordPress
docker compose logs -f wordpress

# Visualizza logs database
docker compose logs -f db

# Riavvia un servizio specifico
docker compose restart wordpress

# Ferma i servizi
docker compose down

# Reset completo (⚠️ ATTENZIONE: cancella tutti i dati!)
docker compose down -v
```

### Scripts di Diagnostica

```bash
# Diagnostica permessi file
./scripts/diagnose-permissions.sh

# Fix automatico permessi
./scripts/fix-permissions.sh

# Diagnostica REST API
./scripts/diagnose-rest-api.sh

# Fix REST API (.htaccess + mod_rewrite)
./scripts/fix-rest-api.sh

# Aumenta limite upload a 100MB
./scripts/increase-upload-limit.sh

# Migra uploads da named volume a bind mount
./scripts/migrate-uploads-to-bind-mount.sh
```

### Verifica Configurazione

```bash
# Verifica settings PHP
docker compose exec wordpress php -i | grep -E "upload_max_filesize|post_max_size|memory_limit"

# Test REST API
curl -I http://localhost:7000/wp-json/

# Verifica permessi directory
docker compose exec wordpress ls -la /var/www/html/wp-content/uploads

# Verifica .htaccess
docker compose exec wordpress cat /var/www/html/.htaccess
```

### Backup e Restore

```bash
# Backup database manuale
docker compose exec db mysqldump -u wordpress -p wordpress > backup.sql

# Restore database
docker compose exec -T db mysql -u wordpress -p wordpress < backup.sql

# Backup file WordPress
tar czf wordpress-backup.tar.gz ./wordpress/

# Backup completo (database + file)
./scripts/backup-all.sh  # Se disponibile
```

---

*Last updated: 17 Ottobre 2025*
