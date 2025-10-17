# WordPress Development Workflow

## 🎯 **Nuovo Setup con Bind Mounts e Versioni Pinnate**

### ✅ **Problemi Risolti:**
- **Versioni consistenti**: Immagini Docker con tag specifici (non `latest`)
- **Codice versionabile**: Files WordPress accessibili nel filesystem locale
- **Plugin/Temi sviluppabili**: Modifica diretta tramite IDE
- **Deploy affidabile**: Stesse versioni in dev/staging/production

### 📁 **Struttura Directory:**
```
/home/ale/docker/aiucd/
├── docker-compose.yml           # Versioni pinnate: wp:6.8.3, mariadb:10.11.5
├── .env / .env.example         # Configurazioni ambiente
├── scripts/
│   ├── manage.sh               # Gestione container
│   └── init-wordpress.sh       # Inizializzazione WordPress
└── wordpress/                  # 🆕 CODICE VERSIONABILE
    ├── wp-content/
    │   ├── themes/             # Temi custom (versionati)
    │   ├── plugins/            # Plugin custom (versionati)
    │   └── uploads/            # Upload utenti (volume Docker)
    ├── wp-config.php           # Config auto-generata
    └── [altri file WP core]    # Core WordPress (versionabili)
```

### 🔧 **Workflow di Sviluppo:**

#### **1. Setup Iniziale**
```bash
# Inizializza la struttura WordPress
./scripts/init-wordpress.sh

# Avvia i servizi
docker compose up -d

# Completa l'installazione WordPress
# http://localhost:8000
```

#### **2. Sviluppo Temi/Plugin**
```bash
# Modifica direttamente i file
code wordpress/wp-content/themes/mytheme/
code wordpress/wp-content/plugins/myplugin/

# I cambiamenti sono immediatamente visibili
# Ricarica semplicemente il browser
```

#### **3. Gestione Codice**
```bash
# Versiona solo quello che serve
git add wordpress/wp-content/themes/
git add wordpress/wp-content/plugins/
git commit -m "Add custom theme/plugin"

# .gitignore gestisce automaticamente:
# - uploads/ (file utenti)
# - wp-config.php (config auto-generata)
# - Opzionalmente core WP files
```

#### **4. Gestione Plugin**
```bash
# Metodo 1: Via WordPress admin (standard)
# http://localhost:8000/wp-admin → Plugin → Installa

# Metodo 2: Download diretto in directory
# wget plugin.zip
# unzip -d wordpress/wp-content/plugins/

# Metodo 3: Git submodule per plugin versioni specifiche
# git submodule add https://github.com/plugin/repo wordpress/wp-content/plugins/plugin-name
```

### 🚀 **Deploy in Produzione:**

#### **Docker Compose Production**
```yaml
# docker-compose.prod.yml
services:
  wordpress:
    image: wordpress:6.8.3-apache  # 🔒 STESSA VERSIONE
    volumes:
      - ./wordpress:/var/www/html:ro  # Read-only in produzione
      - wordpress_uploads_prod:/var/www/html/wp-content/uploads
    environment:
      # Usa variabili ambiente di produzione
      
  db:
    image: mariadb:10.11.5  # 🔒 STESSA VERSIONE
    # ... config produzione
```

#### **Deploy Command**
```bash
# Copia codice su server produzione
rsync -av --exclude='.git' ./wordpress/ server:/path/to/wordpress/

# Deploy con Docker Compose
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

### 🛡️ **Vantaggi della Nuova Configurazione:**

#### **Sviluppo:**
- ✅ **IDE Integration**: IntelliSense, debugging, git integration
- ✅ **Hot Reload**: Cambiamenti immediati senza restart
- ✅ **Version Control**: Temi e plugin completamente versionabili
- ✅ **Backup Selettivo**: Solo uploads e database

#### **Deploy:**
- ✅ **Consistency**: Stesse versioni Docker in tutti gli ambienti
- ✅ **Reliability**: No sorprese da aggiornamenti imprevisti
- ✅ **Rollback**: Facile tornare a versioni precedenti
- ✅ **CI/CD**: Automazione deploy semplificata

### 📋 **Comandi Utili:**

```bash
# Gestione servizi
./scripts/manage.sh start|stop|restart|status

# Sviluppo
./scripts/manage.sh logs-wp        # Log WordPress
./scripts/manage.sh shell-wp       # Shell nel container
./scripts/manage.sh health         # Health check

# Database
./scripts/manage.sh shell-db       # Accesso MySQL
./scripts/manage.sh backup         # Backup database

# Reset ambiente (sviluppo)
./scripts/manage.sh reset          # ⚠️ Cancella tutti i dati
```

### 🔍 **Verifica Setup:**
- **WordPress**: http://localhost:8000 
- **phpMyAdmin**: http://localhost:8080
- **Files locali**: `ls -la wordpress/wp-content/`
- **Versioni**: `docker compose ps` (verifica tag specifici)

---

## 🎉 **Setup Ottimizzato Completato!**

Ora hai un ambiente WordPress professionale con:
- **Versioni stabili e consistenti**
- **Codice completamente versionabile** 
- **Workflow di sviluppo moderno**
- **Deploy affidabile in produzione**