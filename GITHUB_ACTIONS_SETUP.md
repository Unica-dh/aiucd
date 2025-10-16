# 🚀 GitHub Actions Deployment Guide

## Architettura

Questo progetto usa **GitHub Actions con Self-Hosted Runner** per il deployment su server protetto da VPN.

```
┌─────────────────────┐
│   GitHub Actions    │
│   (Trigger Push)    │
└──────────┬──────────┘
           │
           │ Webhook
           ↓
┌─────────────────────┐
│  Self-Hosted Runner │ ← Sul server di produzione
│  (dietro VPN)       │
│                     │
│  ┌───────────────┐  │
│  │ Docker        │  │
│  │ Compose       │  │
│  └───────────────┘  │
└─────────────────────┘
```

## 🔧 Setup Self-Hosted Runner

### 1. Prerequisiti sul Server

```bash
# Installa Docker e Docker Compose
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER

# Logout e login per applicare il gruppo
```

### 2. Installa GitHub Actions Runner

**Sul server di produzione:**

```bash
# Crea directory per il runner
mkdir -p ~/actions-runner && cd ~/actions-runner

# Scarica il runner (verifica la versione più recente su GitHub)
curl -o actions-runner-linux-x64-2.311.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-linux-x64-2.311.0.tar.gz

# Estrai l'archivio
tar xzf ./actions-runner-linux-x64-2.311.0.tar.gz
```

### 3. Configura il Runner

**Vai su GitHub:**

1. Repository → **Settings** → **Actions** → **Runners**
2. Click **"New self-hosted runner"**
3. Seleziona **Linux** e **x64**
4. Copia il **token** mostrato

**Sul server, esegui:**

```bash
# Configura il runner (usa il token copiato da GitHub)
./config.sh --url https://github.com/Unica-dh/aiucd --token YOUR_TOKEN_HERE

# Quando chiede:
# - Runner name: production-server
# - Runner group: Default
# - Labels: self-hosted,Linux,X64
# - Work folder: _work
```

### 4. Installa il Runner come Servizio

```bash
# Installa come servizio systemd
sudo ./svc.sh install

# Avvia il servizio
sudo ./svc.sh start

# Verifica status
sudo ./svc.sh status

# Per vedere i logs
journalctl -u actions.runner.* -f
```

### 5. Configura Directory di Lavoro

```bash
# Crea directory di progetto
sudo mkdir -p /var/www/aiucd
sudo chown $USER:$USER /var/www/aiucd

# La directory backup viene creata automaticamente dal workflow nel progetto
# Non servono permessi speciali perché è locale al progetto

# Il runner lavorerà in ~/actions-runner/_work/aiucd/aiucd
# e deploierà da lì
```

### 6. Crea/Configura .env sul Server

```bash
cd /var/www/aiucd

# Copia .env.example se esiste nel repo, oppure crealo manualmente
nano .env
```

Contenuto del `.env` di produzione:

```bash
# WordPress Database Configuration
WORDPRESS_DB_NAME=wordpress_prod
WORDPRESS_DB_USER=wpuser_prod
WORDPRESS_DB_PASSWORD=YOUR_STRONG_PASSWORD_HERE

# MySQL Root Password
MYSQL_ROOT_PASSWORD=YOUR_ROOT_PASSWORD_HERE

# WordPress Security Keys
# Generate from: https://api.wordpress.org/secret-key/1.1/salt/
WORDPRESS_AUTH_KEY=your_unique_key_here
WORDPRESS_SECURE_AUTH_KEY=your_unique_key_here
WORDPRESS_LOGGED_IN_KEY=your_unique_key_here
WORDPRESS_NONCE_KEY=your_unique_key_here
WORDPRESS_AUTH_SALT=your_unique_salt_here
WORDPRESS_SECURE_AUTH_SALT=your_unique_salt_here
WORDPRESS_LOGGED_IN_SALT=your_unique_salt_here
WORDPRESS_NONCE_SALT=your_unique_salt_here

# Environment
ENVIRONMENT=production
```

**🔒 IMPORTANTE:** Genera chiavi uniche da https://api.wordpress.org/secret-key/1.1/salt/

## 🎯 Come Funziona il Deploy

### Trigger Automatico

Ogni push sul branch `main` triggera automaticamente il deployment:

```bash
# Da locale
git push origin main
# → GitHub Actions parte automaticamente
# → Self-hosted runner sul server esegue il deploy
```

### Trigger Manuale

Puoi anche triggerare manualmente:

1. Vai su GitHub → **Actions**
2. Seleziona workflow **"Deploy to Production"**
3. Click **"Run workflow"** → **"Run workflow"**

### Fasi del Deployment

Il workflow esegue automaticamente:

1. ✅ **Checkout** del codice
2. 💾 **Backup** del database
3. 🔧 **Verifica** configurazione
4. 🐳 **Deploy** container Docker
5. 🏥 **Health check** (WordPress e phpMyAdmin)
6. 🧹 **Cleanup** immagini vecchie
7. 🔴 **Rollback** automatico se fallisce

## 📊 Monitoraggio

### Visualizza Deployment in Corso

1. GitHub → **Actions**
2. Vedi lo status in tempo reale

### Logs sul Server

```bash
# Logs del runner
journalctl -u actions.runner.* -f

# Logs Docker Compose
cd ~/actions-runner/_work/aiucd/aiucd
docker compose logs -f
```

## 🔍 Troubleshooting

### Runner Non Si Connette

```bash
# Verifica status
sudo ./svc.sh status

# Riavvia
sudo ./svc.sh stop
sudo ./svc.sh start

# Verifica connettività
ping github.com
```

### Deploy Fallisce

```bash
# Vai nella directory di lavoro del runner
cd ~/actions-runner/_work/aiucd/aiucd

# Verifica containers
docker compose ps
docker compose logs

# Verifica .env
cat .env
```

### Rollback Manuale

```bash
# Ripristina da backup
cd ~/actions-runner/_work/aiucd/aiucd
LATEST_BACKUP=$(ls -t /var/backups/aiucd/db_backup_*.sql | head -n 1)
docker compose exec -T db mysql -u root -p"${MYSQL_ROOT_PASSWORD}" wordpress < "$LATEST_BACKUP"
```

## 🔒 Sicurezza

- ✅ Runner esegue dietro VPN (nessuna esposizione pubblica)
- ✅ Nessun secret nel repository (tutto sul server)
- ✅ Backup automatico prima di ogni deploy
- ✅ Rollback automatico in caso di errore
- ✅ Health check completo post-deploy

## 📝 Manutenzione

### Aggiorna Runner

```bash
cd ~/actions-runner
sudo ./svc.sh stop
./config.sh remove  # Usa il token da GitHub
# Scarica nuova versione e riconfigura
sudo ./svc.sh install
sudo ./svc.sh start
```

### Gestione Backup

```bash
# Lista backup
ls -lh /var/backups/aiucd/

# Il workflow mantiene automaticamente gli ultimi 10 backup
# Per cambiar questo, modifica .github/workflows/deploy.yml
```

## 🎯 Test del Setup

### Test Locale Prima del Deploy

```bash
# Verifica che il workflow sia valido
cat .github/workflows/deploy.yml

# Commit e push su un branch di test
git checkout -b test-deploy
git add .github/workflows/deploy.yml
git commit -m "Add GitHub Actions deployment"
git push origin test-deploy

# Verifica su GitHub che il workflow sia sintatticamente corretto
```

### Primo Deploy

```bash
# Merge su main per triggerare il primo deploy
git checkout main
git merge test-deploy
git push origin main

# Vai su GitHub Actions e monitora il deployment
```

## 📞 Quick Reference

```bash
# Start runner
sudo ./svc.sh start

# Stop runner
sudo ./svc.sh stop

# Status runner
sudo ./svc.sh status

# Logs runner
journalctl -u actions.runner.* -f

# Logs Docker
docker compose logs -f
```