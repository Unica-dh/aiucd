# Guida Fix Permessi Produzione

## 🔧 Problema Risolto

Abbiamo implementato la soluzione **user mapping** per risolvere tutti i problemi di permessi.

## 📋 Configurazione Richiesta sul Server di Produzione

### Step 1: Ottenere UID e GID dell'utente runner

SSH nel server di produzione e esegui:

```bash
# Identifica l'utente che esegue il GitHub Actions runner
whoami

# Ottieni UID e GID
id -u
id -g
```

**Output esempio**:
```
1000  # UID
1000  # GID
```

### Step 2: Configurare .env in Produzione

Edita il file `.env` sul server di produzione:

```bash
cd /percorso/al/progetto/aiucd
nano .env  # o vim .env
```

Aggiungi queste righe (con i valori ottenuti sopra):

```bash
# Docker User Mapping (IMPORTANTE PER PERMESSI)
DOCKER_UID=1000  # sostituisci con il tuo UID
DOCKER_GID=1000  # sostituisci con il tuo GID
```

### Step 3: Ricostruire i Container

```bash
# Ferma i container
docker compose down

# Riavvia con la nuova configurazione
docker compose up -d

# Verifica che siano partiti
docker compose ps
```

### Step 4: Verificare i Permessi

```bash
# Controlla ownership dei file in wordpress/
ls -la wordpress/ | head -n 10

# I file dovrebbero essere di proprietà del tuo utente, NON di www-data
```

### Step 5: Test Funzionalità WordPress

1. Apri WordPress in browser
2. Vai su **Pagine → Aggiungi Nuova**
3. Crea una pagina di test
4. Clicca **Pubblica**
5. **NON dovrebbe più chiedere credenziali FTP** ✅

## 🎯 Cosa È Stato Modificato

### 1. docker-compose.yml
```yaml
wordpress:
  user: "${DOCKER_UID:-1000}:${DOCKER_GID:-1000}"
  environment:
    APACHE_RUN_USER: "#${DOCKER_UID:-1000}"
    APACHE_RUN_GROUP: "#${DOCKER_GID:-1000}"
```

### 2. .env.example
```bash
DOCKER_UID=1000
DOCKER_GID=1000
```

### 3. GitHub Actions Workflow
- Accetta HTTP 301 come risposta valida
- Logging migliorato per debugging
- Mostra log dei container in caso di errore

## ✅ Benefici della Soluzione

1. **WordPress può scrivere** → Niente più richiesta FTP
2. **Git può fare checkout** → Deploy funziona
3. **Runner può modificare file** → Nessun errore di permessi
4. **Sicurezza mantenuta** → Non servono permessi 777
5. **Performance identica** → Nessun overhead

## 🚨 Troubleshooting

### Se WordPress continua a chiedere FTP:

```bash
# 1. Verifica la configurazione
docker compose exec wordpress env | grep APACHE_RUN

# 2. Controlla i permessi dei file
docker compose exec wordpress ls -la /var/www/html | head -n 10

# 3. Ricrea i container
docker compose down
docker compose up -d --force-recreate
```

### Se il deploy GitHub Actions fallisce:

```bash
# 1. Controlla i log
docker compose logs --tail=50 wordpress

# 2. Verifica .env
cat .env | grep DOCKER_

# 3. Riavvia il runner (se necessario)
sudo systemctl restart actions.runner.*
```

## 📞 Prossimi Passi

Dopo aver configurato .env con i UID/GID corretti:

1. Fai un **push su GitHub** per triggerare il deploy
2. Osserva il workflow GitHub Actions
3. Verifica che l'health check passi
4. Testa la pubblicazione di una pagina WordPress
5. Conferma che non ci siano più richieste FTP

## ✨ Note Finali

- I valori di default (1000) funzionano sulla maggior parte dei sistemi Linux
- Se usi un utente diverso, assicurati di usare il SUO UID/GID
- Questa configurazione funziona sia in development che in production
- I file creati da WordPress saranno modificabili sia da Git che da WordPress stesso
