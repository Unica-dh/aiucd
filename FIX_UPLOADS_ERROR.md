# 🔴 FIX: Impossibile Caricare File in WordPress

## ❌ Problema

**Errore**: "Impossibile creare la directory wp-content/uploads/2025/10. La sua directory genitore è scrivibile dal server?"

## 🎯 Causa

La directory `wp-content/uploads` (che è un **named volume** Docker) ha permessi sbagliati. Il container non può creare subdirectory (anno/mese) per organizzare i file caricati.

## ✅ SOLUZIONE RAPIDA (Sul Server)

```bash
# Esegui questo script sul server di produzione
./scripts/fix-uploads.sh
```

Lo script:
1. ✅ Verifica permessi attuali
2. ✅ Corregge ownership di uploads/
3. ✅ Imposta permessi corretti (755)
4. ✅ Testa scrittura
5. ✅ Riavvia container se necessario

## 📋 Soluzione Manuale

Se lo script non funziona, ecco i comandi manuali:

### Opzione 1: Fix Dentro al Container

```bash
# 1. Entra nel container
docker compose exec wordpress bash

# 2. Crea e sistema permessi
mkdir -p /var/www/html/wp-content/uploads
chown -R $(id -u):$(id -g) /var/www/html/wp-content/uploads
chmod -R 755 /var/www/html/wp-content/uploads

# 3. Verifica
ls -ld /var/www/html/wp-content/uploads
touch /var/www/html/wp-content/uploads/test.txt
rm /var/www/html/wp-content/uploads/test.txt

# 4. Esci
exit
```

### Opzione 2: Fix del Volume

```bash
# 1. Ottieni il tuo UID/GID
MY_UID=$(id -u)
MY_GID=$(id -g)

# 2. Fix usando un container temporaneo
docker run --rm \
    -v aiucd_wordpress_uploads:/uploads \
    alpine:latest \
    sh -c "chown -R $MY_UID:$MY_GID /uploads && chmod -R 755 /uploads"

# 3. Riavvia WordPress
docker compose restart wordpress
```

### Opzione 3: Ricreare il Volume (ULTIMO RESORT)

⚠️ **ATTENZIONE**: Questo cancella tutti i file già caricati!

```bash
# 1. Stop containers
docker compose down

# 2. Rimuovi il volume
docker volume rm aiucd_wordpress_uploads

# 3. Riavvia (ricreerà il volume)
docker compose up -d

# 4. Fix permessi sul nuovo volume
./scripts/fix-uploads.sh
```

## 🧪 Test

Dopo il fix:

1. Vai in WordPress Admin
2. **Media → Aggiungi Nuovo**
3. Carica un'immagine
4. ✅ **Dovrebbe funzionare!**

## 🔍 Diagnostica

### Verifica Permessi

```bash
# Dentro al container
docker compose exec wordpress ls -ld /var/www/html/wp-content/uploads

# Dovrebbe mostrare:
# drwxr-xr-x 1001 1001 ... /var/www/html/wp-content/uploads
```

### Test Scrittura

```bash
# Test veloce
docker compose exec wordpress touch /var/www/html/wp-content/uploads/.test
docker compose exec wordpress rm /var/www/html/wp-content/uploads/.test

# Se non da errori = OK ✅
```

### Verifica Configurazione WordPress

```bash
# Controlla le costanti WordPress
docker compose exec wordpress wp config get --allow-root

# Cerca:
# FS_METHOD = 'direct'  ✅ corretto
```

## 🎯 Causa Tecnica del Problema

### Come Funziona:

1. **docker-compose.yml** definisce:
   ```yaml
   volumes:
     - ./wordpress:/var/www/html
     - wordpress_uploads:/var/www/html/wp-content/uploads
   ```

2. **Named volume** `wordpress_uploads` viene creato da Docker

3. **Problema**: Il volume viene creato con ownership root:root o www-data

4. **Container gira come**: UID:1001 (il tuo utente)

5. **Conflitto**: Container non può creare directory in un volume con owner diverso

### La Soluzione:

Correggere l'ownership del volume per matchare l'UID del container (1001:1001).

## 💡 Prevenzione Futura

### Configurazione Corretta .env

Assicurati che `.env` contenga:

```bash
DOCKER_UID=1001
DOCKER_GID=1001
```

### Dopo Ogni Rebuild

Se fai `docker compose down -v` (che rimuove i volumi), dopo il restart esegui:

```bash
./scripts/fix-uploads.sh
```

## 🚨 Troubleshooting

### Errore: "Permission denied" anche dopo il fix

```bash
# 1. Verifica che il container giri con UID corretto
docker compose exec wordpress id

# Dovrebbe mostrare: uid=1001 gid=1001

# 2. Se mostra uid=33 (www-data), controlla .env
cat .env | grep DOCKER_

# 3. Riavvia container
docker compose down
docker compose up -d
```

### Errore: "chown: Operation not permitted"

```bash
# Devi eseguire il fix come utente che ha avviato i container
# O usa il metodo "docker run" che gira come root dentro il container temporaneo
```

### Upload Funziona ma Crea Directory con Permessi Sbagliati

WordPress crea le directory uploads con permessi che dipendono dalla configurazione PHP:

```bash
# Controlla umask dentro al container
docker compose exec wordpress sh -c 'umask'

# Dovrebbe essere: 0022 (che crea dir con 755)
```

## ✅ Checklist Finale

Dopo il fix, verifica:

- [ ] `./scripts/fix-uploads.sh` eseguito con successo
- [ ] Test scrittura funziona dentro al container
- [ ] Upload immagine in WordPress Media → OK
- [ ] Immagine visibile in libreria media
- [ ] Immagine inseribile in pagina/articolo

---

## 🎁 Script Creato

Ho creato `scripts/fix-uploads.sh` che:
- Diagnostica automaticamente il problema
- Corregge ownership e permessi
- Testa la scrittura
- Riavvia container se necessario
- Gestisce diversi scenari di errore

**Usalo ogni volta** che hai problemi con gli upload!
