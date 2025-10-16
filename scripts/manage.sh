#!/bin/bash

# Script di utility per gestione WordPress Docker Compose
# Posizione: /home/ale/docker/aiucd/scripts/manage.sh

PROJECT_DIR="/home/ale/docker/aiucd"
cd "$PROJECT_DIR"

case "$1" in
    "start")
        echo "🚀 Avvio servizi WordPress..."
        docker compose up -d
        echo "✅ Servizi avviati!"
        echo "🌐 WordPress: http://localhost:8000"
        echo "🗄️  phpMyAdmin: http://localhost:8080"
        ;;
    "stop")
        echo "⏹️  Arresto servizi (mantiene container)..."
        docker compose stop
        echo "✅ Servizi arrestati!"
        ;;
    "down")
        echo "🛑 Spegnimento completo (rimuove container)..."
        docker compose down
        echo "✅ Container rimossi!"
        ;;
    "restart")
        echo "🔄 Riavvio servizi..."
        docker compose stop
        docker compose start
        echo "✅ Servizi riavviati!"
        ;;
    "rebuild")
        echo "🔄 Ricostruzione completa..."
        docker compose down
        docker compose up -d
        echo "✅ Servizi ricostruiti!"
        ;;
    "status")
        echo "📊 Status servizi:"
        docker compose ps
        ;;
    "logs")
        echo "📋 Logs servizi (Ctrl+C per uscire):"
        docker compose logs -f
        ;;
    "logs-wp")
        echo "📋 Logs WordPress (Ctrl+C per uscire):"
        docker compose logs -f wordpress
        ;;
    "logs-db")
        echo "📋 Logs Database (Ctrl+C per uscire):"
        docker compose logs -f db
        ;;
    "shell-wp")
        echo "🐚 Accesso shell WordPress container..."
        docker compose exec wordpress bash
        ;;
    "shell-db")
        echo "🐚 Accesso MySQL/MariaDB..."
        docker compose exec db mysql -u wpuser -p
        ;;
    "backup")
        echo "💾 Backup database..."
        mkdir -p backups
        docker compose exec db mysqldump -u wpuser -p wordpress > backups/wordpress_$(date +%Y%m%d_%H%M%S).sql
        echo "✅ Backup salvato in backups/"
        ;;
    "reset")
        echo "⚠️  ATTENZIONE: Questo cancellerà tutti i dati!"
        read -p "Sei sicuro? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            docker compose down -v
            echo "🗑️  Volumi cancellati. Riavvio servizi..."
            docker compose up -d
            echo "✅ Ambiente resettato!"
        else
            echo "❌ Operazione annullata."
        fi
        ;;
    "health")
        echo "🏥 Health check servizi..."
        echo -n "WordPress (8000): "
        curl -s -o /dev/null -w "%{http_code}" http://localhost:8000 && echo " ✅" || echo " ❌"
        echo -n "phpMyAdmin (8080): "
        curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 && echo " ✅" || echo " ❌"
        ;;
    *)
        echo "🐳 WordPress Docker Manager"
        echo ""
        echo "Utilizzo: $0 [comando]"
        echo ""
        echo "Comandi disponibili:"
        echo "  start      - Avvia tutti i servizi"
        echo "  stop       - Ferma servizi (mantiene container e dati)"
        echo "  down       - Spegne e rimuove container (mantiene volumi)"
        echo "  restart    - Riavvia servizi (stop + start)"
        echo "  rebuild    - Ricostruzione completa (down + up)"
        echo "  status     - Mostra lo status dei container"
        echo "  logs       - Mostra logs di tutti i servizi"
        echo "  logs-wp    - Mostra logs solo WordPress"
        echo "  logs-db    - Mostra logs solo Database"
        echo "  shell-wp   - Accesso shell WordPress container"
        echo "  shell-db   - Accesso MySQL/MariaDB"
        echo "  backup     - Backup del database"
        echo "  reset      - Reset completo (CANCELLA TUTTI I DATI!)"
        echo "  health     - Health check dei servizi"
        echo ""
        echo "Accesso diretto:"
        echo "  WordPress: http://localhost:8000"
        echo "  phpMyAdmin: http://localhost:8080"
        ;;
esac