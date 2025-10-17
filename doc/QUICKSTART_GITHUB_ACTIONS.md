# 🎯 Quick Start: Deployment con GitHub Actions

## ✅ Test Locale Completato!

Il workflow di deployment è stato testato e funziona correttamente.

```
✅ Workflow YAML valido
✅ File necessari presenti
✅ Docker Compose configurato
✅ Immagini con versioni pinned
✅ Health check funzionante
✅ Deploy test successful
```

## 🚀 Setup in 3 Passi

### Passo 1: Commit e Push su GitHub

```bash
# Aggiungi tutti i file del progetto
git add .
git commit -m "Add GitHub Actions deployment workflow"
git push origin main
```

### Passo 2: Configura Self-Hosted Runner sul Server

**Sul server di produzione (dietro VPN):**

```bash
# 1. Installa Docker se non presente
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
# Logout e login

# 2. Scarica GitHub Actions Runner
mkdir -p ~/actions-runner && cd ~/actions-runner
curl -o actions-runner-linux-x64-2.311.0.tar.gz -L \
  https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-linux-x64-2.311.0.tar.gz
tar xzf ./actions-runner-linux-x64-2.311.0.tar.gz

# 3. Ottieni token da GitHub
# Vai su: https://github.com/Unica-dh/aiucd/settings/actions/runners/new

# 4. Configura il runner
./config.sh --url https://github.com/Unica-dh/aiucd --token YOUR_TOKEN_HERE
# Runner name: production-server
# Labels: default
# Work folder: _work

# 5. Installa come servizio
sudo ./svc.sh install
sudo ./svc.sh start

# 6. Verifica
sudo ./svc.sh status
```

### Passo 3: Configura .env sul Server

```bash
# Nella directory di lavoro del runner
cd ~/actions-runner/_work/aiucd/aiucd

# Crea .env di produzione
nano .env
```

Usa credenziali **diverse** da sviluppo! Genera chiavi da: https://api.wordpress.org/secret-key/1.1/salt/

## 🎮 Come Usare

### Deploy Automatico

Ogni push su `main` triggera il deploy:

```bash
git push origin main
# → Deploy automatico parte!
```

### Deploy Manuale

1. Vai su: https://github.com/Unica-dh/aiucd/actions
2. Seleziona "Deploy to Production"
3. Click "Run workflow" → "Run workflow"

### Monitoraggio

Segui il deploy in tempo reale:
- **GitHub**: https://github.com/Unica-dh/aiucd/actions
- **Server logs**: `journalctl -u actions.runner.* -f`

## 📊 Cosa Fa il Workflow

```
1. 📥 Checkout del codice
2. 💾 Backup automatico database
3. 🔧 Verifica configurazione
4. 🐳 Deploy Docker containers
5. 🏥 Health check (30 tentativi)
6. 🧹 Cleanup immagini vecchie
   └─→ ✅ Success
   └─→ ❌ Rollback automatico
```

## 🔧 Troubleshooting

### Runner Non Si Connette

```bash
# Sul server
cd ~/actions-runner
sudo ./svc.sh status
sudo ./svc.sh restart

# Logs
journalctl -u actions.runner.* -f
```

### Deploy Fallisce

```bash
# Vai su GitHub Actions e vedi i logs
# Sul server:
cd ~/actions-runner/_work/aiucd/aiucd
docker compose logs
./scripts/manage.sh status
```

### Rollback Manuale

```bash
cd ~/actions-runner/_work/aiucd/aiucd

# Lista backup disponibili
ls -lh /var/backups/aiucd/

# Restore
BACKUP="/var/backups/aiucd/db_backup_XXXXXX.sql"
docker compose exec -T db mysql -u root -p"${MYSQL_ROOT_PASSWORD}" wordpress < "$BACKUP"
```

## 📝 File Importanti

```
.github/workflows/deploy.yml     # Workflow GitHub Actions
GITHUB_ACTIONS_SETUP.md         # Documentazione completa
scripts/test-deployment.sh      # Test locale del workflow
scripts/manage.sh               # Gestione container locale
docker-compose.yml              # Configurazione servizi
```

## 🔒 Sicurezza

✅ Self-hosted runner (nessuna esposizione server)  
✅ Lavora dietro VPN  
✅ Backup automatico prima di ogni deploy  
✅ Rollback automatico se fallisce  
✅ Health check completo  
✅ Nessun secret nel repository  

## 📚 Documentazione Completa

Vedi `GITHUB_ACTIONS_SETUP.md` per:
- Setup dettagliato runner
- Troubleshooting avanzato
- Gestione backup
- Manutenzione

---

## ✨ Ready to Deploy!

Una volta configurato il runner sul server:

```bash
git push origin main
```

E il deploy partirà automaticamente! 🚀