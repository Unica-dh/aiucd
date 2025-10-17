# 🎯 FIX COMPLETO - Permessi WordPress Docker

## ✅ MODIFICHE IMPLEMENTATE

### 1. docker-compose.yml - User Mapping
Aggiunto mapping UID/GID per evitare conflitti di permessi:
- Container WordPress ora gira con UID/GID dell'utente host
- Apache configurato per usare lo stesso utente
- File creati hanno ownership corretta

### 2. .env.example - Nuove Variabili
Aggiunte variabili di configurazione:
- `DOCKER_UID=1000` (default)
- `DOCKER_GID=1000` (default)

### 3. GitHub Actions Workflow - Miglioramenti
- Accetta HTTP 301 come risposta valida (redirect WordPress)
- Logging dettagliato dei container
- Mostra log in caso di errore
- Rimosso flag --build non necessario

### 4. Documentazione
- `PERMISSION_ANALYSIS.md`: Analisi dettagliata del problema
- `PRODUCTION_FIX_GUIDE.md`: Guida step-by-step per la produzione

## 🔧 AZIONE RICHIESTA SUL SERVER DI PRODUZIONE

**PRIMA** del prossimo deploy, devi configurare il file `.env` sul server:

```bash
# 1. SSH nel server di produzione
ssh user@server

# 2. Vai nella directory del progetto
cd /percorso/al/progetto/aiucd

# 3. Ottieni UID e GID
id -u  # esempio output: 1000
id -g  # esempio output: 1000

# 4. Edita .env e aggiungi:
nano .env
```

Aggiungi queste righe (con i tuoi valori):
```
DOCKER_UID=1000
DOCKER_GID=1000
```

```bash
# 5. Riavvia i container
docker compose down
docker compose up -d
```

## 🎁 RISULTATI ATTESI

Dopo questa configurazione:

✅ **WordPress potrà scrivere file** (no più FTP)
✅ **Deploy GitHub Actions funzionerà** (no permission denied)
✅ **Git checkout pulito** (runner può modificare file)
✅ **Pubblicazione pagine WordPress** (senza credenziali FTP)
✅ **Sicurezza mantenuta** (no permessi 777)

## 📝 NOTE

- Se UID/GID non sono specificati nel .env, usa default 1000
- Sulla maggior parte dei sistemi Linux, il primo utente ha UID/GID 1000
- Questa soluzione funziona sia in development che production
- Nessuna modifica al codice WordPress necessaria

## 🚀 PROSSIMI STEP

1. Configura `.env` sul server (come sopra)
2. Commit e push di queste modifiche
3. Osserva il deploy GitHub Actions
4. Verifica che l'health check passi
5. Testa la pubblicazione in WordPress
