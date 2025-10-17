# 🔴 FIX RAPIDO: Errore "La risposta non è una risposta JSON valida"

## ⚡ SOLUZIONE RAPIDA (99% dei casi)

### Sul Server di Produzione:

```bash
# 1. Esegui lo script di fix
./scripts/fix-rest-api.sh
```

### Poi, in WordPress Admin:

1. **Login** → `http://tuo-dominio:7000/wp-admin`
2. **Vai a**: `Impostazioni → Permalink` 
3. **Clicca**: `Salva modifiche` (non serve cambiare nulla)
4. **Prova di nuovo** a pubblicare

✅ **Questo risolve il problema nel 99% dei casi!**

---

## 🔍 Cosa Fa lo Script

1. Verifica/crea il file `.htaccess` con configurazione corretta
2. Abilita `mod_rewrite` di Apache
3. Controlla permessi file
4. Testa le REST API
5. Mostra eventuali errori PHP

---

## 🧪 Diagnostica Dettagliata (opzionale)

Se vuoi vedere cosa sta succedendo:

```bash
./scripts/diagnose-rest-api.sh
```

---

## 🎯 Causa del Problema

L'errore "La risposta non è una risposta JSON valida" accade quando:

1. **File `.htaccess` mancante/errato** → URL rewriting non funziona → REST API non raggiungibile
2. **Permalink non configurati** → WordPress non sa come gestire le URL REST
3. **mod_rewrite disabilitato** → Apache non può riscrivere le URL
4. **Errori PHP** → Output corrotto, non è JSON valido

---

## 📋 Procedura Manuale (se gli script non funzionano)

### 1. Crea/Verifica .htaccess

```bash
cd /percorso/al/progetto/aiucd

# Verifica se esiste
ls -la wordpress/.htaccess

# Se non esiste, crealo:
cat > wordpress/.htaccess << 'EOF'
# BEGIN WordPress
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteRule .* - [E=HTTP_AUTHORIZATION:%{HTTP:Authorization}]
RewriteBase /
RewriteRule ^index\.php$ - [L]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.php [L]
</IfModule>
# END WordPress
EOF

# Fix permessi
chown $(id -u):$(id -g) wordpress/.htaccess
chmod 644 wordpress/.htaccess
```

### 2. Abilita mod_rewrite

```bash
docker compose exec wordpress a2enmod rewrite
docker compose restart wordpress
```

### 3. Rigenera Permalink in WordPress Admin

1. Login WordPress Admin
2. `Impostazioni → Permalink`
3. Clicca `Salva modifiche`

---

## ✅ Come Verificare che Funzioni

### Test REST API:

```bash
curl -I http://localhost:7000/wp-json/
```

**Output corretto**:
```
HTTP/1.1 200 OK
Content-Type: application/json
```

**Output errato**:
```
HTTP/1.1 404 Not Found
```

### Test Pubblicazione:

1. Vai in WordPress → Pagine → Aggiungi Nuova
2. Scrivi qualcosa
3. Clicca "Pubblica"
4. **Dovrebbe funzionare senza errori** ✅

---

## 🚨 Se Continua a Non Funzionare

### A. Controlla i Log

```bash
# Log WordPress/Apache
docker compose logs wordpress | tail -n 50

# Log errori PHP (dentro al container)
docker compose exec wordpress tail -f /var/log/apache2/error.log
```

### B. Disabilita Plugin

1. WordPress Admin → Plugin
2. Disabilita tutti i plugin
3. Prova a pubblicare
4. Se funziona, riattiva uno alla volta per trovare il colpevole

### C. Cambia Tema Temporaneamente

1. WordPress Admin → Aspetto → Temi
2. Attiva "Twenty Twenty-Four" (tema default)
3. Prova a pubblicare
4. Se funziona, il problema è nel tema

### D. Controlla Browser Console

1. Apri DevTools (F12) nel browser
2. Vai alla tab "Console"
3. Prova a pubblicare
4. Guarda se ci sono errori JavaScript

---

## 🎁 Risoluzione Problemi Comuni

### Errore: "mod_rewrite already enabled"
✅ Buono! Vai avanti con gli altri step.

### Errore: ".htaccess permission denied"
```bash
sudo chown $(id -u):$(id -g) wordpress/.htaccess
chmod 644 wordpress/.htaccess
```

### REST API ritorna 404
```bash
# Forza flush delle rewrite rules
docker compose exec wordpress wp rewrite flush --hard
```

### PHP errors nel log
- Leggi l'errore specifico
- Spesso è un plugin/tema incompatibile
- Prova a disabilitare plugin

---

## 💡 Prevenzione Futura

Dopo aver risolto:

1. ✅ Il file `.htaccess` sarà versionato in Git
2. ✅ I deploy futuri manterranno la configurazione
3. ✅ mod_rewrite rimarrà abilitato
4. ✅ I permalink saranno configurati correttamente

**Non dovresti più avere questo problema!**

---

## 📞 Hai Ancora Problemi?

Se dopo tutti questi step il problema persiste:

1. Esegui diagnostica completa: `./scripts/diagnose-rest-api.sh`
2. Copia l'output completo
3. Controlla se ci sono errori PHP specifici
4. Verifica che l'URL del sito in `Impostazioni → Generali` sia corretto

Il problema è quasi sempre uno dei 3:
- ❌ `.htaccess` mancante/errato
- ❌ Permalink non salvati
- ❌ Plugin/tema che rompe JSON output
