# WordPress Docker Compose Setup

## 📋 Requisiti del Progetto

### Obiettivo
Realizzare un sito WordPress completo utilizzando Docker Compose per lo sviluppo e la produzione, con configurazione semplificata e ottimizzata.

### Specifiche Tecniche

#### 🔧 Configurazione di Base
- **Porta di esposizione**: `8000` (HTTP)
- **Database**: MariaDB/MySQL
- **Web Server**: Apache (integrato nel container WordPress)
- **PHP**: Ultima versione stabile supportata da WordPress
- **Gestione SSL**: Non necessaria (gestita lato server)

#### 🐳 Servizi Docker
1. **WordPress** (`wordpress:latest`)
   - Container principale con WordPress + Apache + PHP
   - Esposto sulla porta 8000
   - Volumi persistenti per files e uploads

2. **Database** (`mariadb:latest`)
   - Database MariaDB per WordPress
   - Volumi persistenti per i dati
   - Rete interna (non esposta esternamente)

3. **phpMyAdmin** (opzionale)
   - Interfaccia web per gestione database
   - Esposto su porta secondaria per amministrazione

#### 📁 Struttura Directory
```
/home/ale/docker/aiucd/
├── README.md
├── docker-compose.yml          # Configurazione principale
├── .env                        # Variabili d'ambiente (non versionato)
├── .env.example               # Template variabili d'ambiente
├── wordpress/                 # Volume dati WordPress
│   ├── wp-content/           # Temi, plugin, uploads
│   └── wp-config.php         # (generato automaticamente)
├── database/                 # Volume dati MariaDB
└── logs/                     # Log applicazioni (opzionale)
```

#### 🔐 Configurazione Sicurezza
- **Credenziali database**: Gestite tramite file `.env`
- **WordPress secrets**: Chiavi di sicurezza generate automaticamente
- **Accesso database**: Solo rete interna Docker
- **File sensibili**: `.env` escluso dal versioning

#### 🌐 Accesso Applicazione
- **WordPress**: `http://localhost:8000`
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

### Core Features
- ✅ **WordPress** ultima versione
- ✅ **Database MariaDB** con persistenza
- ✅ **Volumi persistenti** per dati e uploads
- ✅ **Configurazione via environment** (.env)
- ✅ **Rete isolata** per sicurezza
- ✅ **Logs centralizzati**

### Features Opzionali
- 🔧 **phpMyAdmin** per gestione database
- 🔧 **Redis cache** per performance
- 🔧 **Backup automatici** dei volumi
- 🔧 **Health checks** per monitoraggio

### Features Escluse
- ❌ **Gestione SSL/HTTPS** (gestita lato server)
- ❌ **Reverse proxy Nginx** (non necessario)
- ❌ **Load balancing** (single instance)

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

## 📚 Struttura Implementazione

### Fase 1: Setup Base
1. Creazione `docker-compose.yml`
2. Configurazione `.env` e `.env.example`
3. Test funzionamento base

### Fase 2: Ottimizzazioni
1. Aggiunta phpMyAdmin (opzionale)
2. Configurazione logging
3. Scripts di utility

### Fase 3: Produzione Ready
1. Health checks
2. Backup strategy
3. Monitoring setup

## 🔍 Note Tecniche

- **Networking**: Rete bridge personalizzata per isolamento
- **Volumes**: Named volumes per migliore gestione Docker
- **Environment**: Separazione completa tra configurazione e codice
- **Security**: Principio least privilege per accessi database
- **Performance**: Configurazione ottimizzata per uso locale/server

---

## 📞 Quick Start

Una volta completata l'implementazione:

```bash
# Clone/naviga nella directory
cd /home/ale/docker/aiucd

# Copia e configura le variabili d'ambiente
cp .env.example .env
# Modifica .env con i tuoi valori

# Avvia i servizi
docker-compose up -d

# Accedi a WordPress
# http://localhost:8000
```

## 🔧 Comandi Utili

```bash
# Visualizza status servizi
docker-compose ps

# Visualizza logs
docker-compose logs -f

# Ferma i servizi
docker-compose down

# Reset completo (attenzione: cancella i dati!)
docker-compose down -v
```