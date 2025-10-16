# WordPress Development Directory

Questa directory contiene i file WordPress per lo sviluppo.

## Struttura:
- `wp-content/themes/` - Temi personalizzati (versionati)
- `wp-content/plugins/` - Plugin personalizzati (versionati)  
- `wp-content/uploads/` - File caricati dagli utenti (NON versionati)
- `wp-config.php` - Configurazione (generata automaticamente)

## Note:
- I file core WordPress sono versionati per consistency
- Gli uploads sono gestiti da un volume Docker separato
- Modifica direttamente i file per lo sviluppo di temi/plugin
