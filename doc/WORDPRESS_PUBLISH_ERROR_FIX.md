# 🚨 ERRORE PUBBLICAZIONE WORDPRESS - SOLUZIONE

## ❌ Problema

**Errore**: "Pubblicazione fallita. La risposta non è una risposta JSON valida"

**Causa**: Questo è l'errore classico delle **REST API di WordPress** quando ci sono problemi di permessi sui file.

## 🔍 Perché Succede

WordPress usa le REST API per salvare/pubblicare contenuti. Quando WordPress non può scrivere su file critici (`.htaccess`, file in `wp-content/`, etc.), le API REST falliscono e restituiscono HTML invece di JSON → errore.

**Root cause**: I file in `wordpress/` appartengono a un utente, ma il container gira come un altro utente.

## ✅ SOLUZIONE IMMEDIATA (Sul Server di Produzione)

### Opzione 1: Script Automatico (RACCOMANDATO)

Ho creato uno script che fa tutto automaticamente:

```bash
# Sul server di produzione
cd /percorso/al/progetto/aiucd

# Esegui lo script di fix
./scripts/fix-permissions.sh
```

Lo script:
- ✅ Rileva automaticamente il tuo UID/GID
- ✅ Configura .env con i valori corretti
- ✅ Corregge ownership di tutti i file
- ✅ Riavvia i container con la configurazione corretta

### Opzione 2: Manuale (Step by Step)

```bash
# 1. SSH nel server di produzione
ssh utente@server

# 2. Vai nella directory del progetto
cd /percorso/al/progetto/aiucd

# 3. Verifica il problema (diagnostica)
./scripts/diagnose-permissions.sh

# 4. Ottieni il tuo UID e GID
id -u  # esempio: 1000
id -g  # esempio: 1000

# 5. Edita .env e aggiungi (o modifica):
nano .env
```

Aggiungi queste righe:
```bash
# Docker User Mapping (IMPORTANTE!)
DOCKER_UID=1000  # <-- sostituisci con il TUO valore da id -u
DOCKER_GID=1000  # <-- sostituisci con il TUO valore da id -g
```

```bash
# 6. Ferma i container
docker compose down

# 7. Correggi ownership dei file esistenti
docker run --rm -v "$(pwd)/wordpress:/workspace" alpine:latest \
    sh -c "chown -R $(id -u):$(id -g) /workspace"

# 8. Riavvia con la nuova configurazione
docker compose up -d

# 9. Verifica che funzioni
docker compose ps
docker compose logs wordpress | tail -n 20
```

## 🧪 Verifica della Soluzione

1. **Apri WordPress** nel browser
2. **Crea una nuova pagina** o articolo
3. **Clicca Pubblica**
4. **Dovrebbe funzionare** senza errori o richieste FTP! ✅

## 🔧 Script Disponibili

Ho creato due script helper:

### 1. `diagnose-permissions.sh` - Diagnostica
```bash
./scripts/diagnose-permissions.sh
```

Mostra:
- UID/GID dell'utente corrente
- Configurazione .env
- Ownership dei file WordPress
- Raccomandazioni specifiche

### 2. `fix-permissions.sh` - Fix Automatico
```bash
./scripts/fix-permissions.sh
```

Risolve automaticamente:
- Configura .env
- Corregge ownership file
- Riavvia container
- Verifica la configurazione

## 📊 Cosa Succede Dopo il Fix

**Prima** (problema):
```
File wordpress/: owned by UID 33 (www-data) o altro
Container runs as: UID 1000 (default)
→ Container can't write → REST API fails
```

**Dopo** (soluzione):
```
File wordpress/: owned by UID 1000 (tuo utente)
Container runs as: UID 1000 (configurato via .env)
→ Container can write → REST API works! ✅
```

## 🎯 Perché Questa È la Soluzione Corretta

1. **User Mapping**: Il container gira con lo stesso UID/GID del tuo utente
2. **No sudo**: Non servono permessi 777 pericolosi
3. **Sicurezza**: Ownership corretta e permessi appropriati
4. **Deploy-friendly**: Git può fare checkout, WordPress può scrivere
5. **Permanente**: Una volta configurato, funziona sempre

## 🚨 Se Continua a Non Funzionare

```bash
# 1. Verifica che i container stiano girando
docker compose ps

# 2. Controlla i log per errori
docker compose logs wordpress

# 3. Verifica l'ownership dentro al container
docker compose exec wordpress ls -la /var/www/html | head -n 10

# 4. Verifica che .env sia stato caricato
docker compose config | grep -A 2 wordpress

# 5. Prova a ricreare completamente i container
docker compose down
docker compose up -d --force-recreate
```

## 📝 Note Importanti

- ⚠️ **Devi eseguire questi comandi sul SERVER DI PRODUZIONE**, non in locale
- ✅ Il fix è **permanente** - devi farlo solo una volta
- ✅ Dopo il fix, tutti i deploy futuri funzioneranno correttamente
- ✅ WordPress potrà installare plugin, aggiornare temi, caricare file, ecc.

## 🎁 File Committati

Aggiungo al repository:
- ✅ `scripts/diagnose-permissions.sh` - Script diagnostica
- ✅ `scripts/fix-permissions.sh` - Script fix automatico
- ✅ `WORDPRESS_PUBLISH_ERROR_FIX.md` - Questa guida

Fai commit e push, poi esegui il fix sul server!
