# Analisi Problemi di Permessi - WordPress Docker

## 🔴 Problemi Identificati

### 1. GitHub Actions Deploy Fallisce
- Health check timeout (30 tentativi)
- HTTP response: 301/243 invece di 200/302
- Apache ServerName warnings (non critico)

### 2. WordPress in Produzione: Richiesta FTP
**Sintomo**: Impossibile pubblicare pagine, WordPress chiede credenziali FTP
**Causa**: WordPress non ha permessi di scrittura sul filesystem
**Configurazione attuale**: `FS_METHOD=direct` in wp-config.php (dovrebbe bypassare FTP)

### 3. Conflitto Permessi Git/Docker
**Problema**: Bind mount `./wordpress:/var/www/html` crea conflitti di ownership
- Files creati da Apache container (www-data, UID 33)
- Runner GitHub Actions non può modificarli
- Git checkout fallisce per permission denied

## 🔍 Architettura Attuale

```
docker-compose.yml:
  wordpress:
    volumes:
      - ./wordpress:/var/www/html              # BIND MOUNT
      - wordpress_uploads:/var/www/html/wp-content/uploads  # NAMED VOLUME
```

### Problemi dell'Architettura Attuale:

1. **Bind Mount ./wordpress**
   - ✅ Pro: Codice versionabile in Git
   - ❌ Contro: UID/GID mismatch tra container e host
   - ❌ Contro: Runner non può fare checkout pulito
   - ❌ Contro: www-data container non può scrivere

2. **FS_METHOD=direct**
   - Teoricamente bypassa FTP
   - Ma se i permessi sono sbagliati, non funziona comunque

## 🎯 Possibili Soluzioni

### Opzione A: User Mapping nel Container (RACCOMANDATO)
Configurare il container WordPress per usare lo stesso UID/GID dell'utente host

```yaml
wordpress:
  user: "${UID}:${GID}"  # Usa UID/GID dell'utente host
  volumes:
    - ./wordpress:/var/www/html
```

**Pro**: 
- Permessi corretti automaticamente
- Git checkout funziona
- WordPress può scrivere

**Contro**:
- Richiede .env configurato con UID/GID
- Potrebbe richiedere rebuild dei container

### Opzione B: Named Volume invece di Bind Mount
Usare volume Docker gestito invece di ./wordpress

```yaml
wordpress:
  volumes:
    - wordpress_data:/var/www/html  # NAMED VOLUME
```

**Pro**:
- No conflitti UID/GID
- WordPress può sempre scrivere
- Performance migliori

**Contro**:
- ❌ Codice non versionabile facilmente
- ❌ Non possiamo committare wp-config.php
- ❌ Deploy via Git diventa complesso

### Opzione C: Permessi 777 (NON RACCOMANDATO)
Dare permessi universali a wordpress/

**Pro**: Funziona sempre

**Contro**:
- ❌ Security risk enorme
- ❌ Non è la soluzione corretta
- ❌ Problemi con SELinux/AppArmor

### Opzione D: Entrypoint Script con chown
Script che sistema i permessi all'avvio del container

**Pro**: Automatico

**Contro**:
- Lento su directory grandi
- Richiede custom Dockerfile

## 📊 Informazioni Necessarie per Decidere

### Da Verificare nel Prossimo Deploy:
1. **UID/GID runner**: Chi esegue GitHub Actions?
2. **UID/GID files**: Chi possiede i file in wordpress/?
3. **UID www-data**: Quale UID ha www-data nel container?
4. **HTTP Response**: Perché 301/243 invece di 200?

### Step Diagnostico Aggiunto
Ho aggiunto uno step diagnostico nel workflow per raccogliere queste info.

## 🚀 Strategia Consigliata

1. **SHORT TERM** (Fix immediato):
   - Eseguire deploy con diagnostica
   - Analizzare output permessi
   - Fix temporaneo basato sui dati

2. **LONG TERM** (Soluzione corretta):
   - Implementare **Opzione A** (User Mapping)
   - Configurare .env con UID/GID corretti
   - Testare che WordPress possa scrivere
   - Verificare che Git checkout funzioni
   - Verificare che deploy GitHub Actions funzioni

## 📝 Note Importanti

- `FS_METHOD=direct` è già configurato ma non funziona (perché permessi wrong)
- Il problema FTP in produzione = filesystem non writable by www-data
- Bind mount è giusto per development, ma serve user mapping
- Named volume sarebbe meglio per production ma perde versionabilità

## ⏭️ Prossimi Passi

1. ✅ Deploy con diagnostica aggiunta
2. ⏳ Analizzare output diagnostica
3. ⏳ Decidere tra Opzione A o B
4. ⏳ Implementare soluzione
5. ⏳ Testare deploy completo
6. ⏳ Verificare pubblicazione pagine WordPress
