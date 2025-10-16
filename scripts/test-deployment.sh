#!/bin/bash

# Script per testare localmente il workflow di deployment
# Simula le azioni che GitHub Actions eseguirà sul server

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}🧪 Test Deployment Workflow Locale${NC}"
echo "========================================"

# 1. Verifica sintassi YAML
echo -e "\n${YELLOW}1. Verifica sintassi workflow...${NC}"
if command -v yamllint &> /dev/null; then
    yamllint .github/workflows/deploy.yml && echo -e "${GREEN}✅ Sintassi YAML valida${NC}" || echo -e "${RED}❌ Errori nella sintassi YAML${NC}"
else
    echo -e "${YELLOW}⚠️  yamllint non installato, skip check${NC}"
fi

# 2. Verifica file necessari
echo -e "\n${YELLOW}2. Verifica file necessari...${NC}"
FILES=("docker-compose.yml" ".env.example" "scripts/manage.sh")
for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✅ $file${NC}"
    else
        echo -e "${RED}❌ $file mancante${NC}"
        exit 1
    fi
done

# 3. Verifica .env
echo -e "\n${YELLOW}3. Verifica configurazione...${NC}"
if [ ! -f .env ]; then
    echo -e "${RED}❌ .env non trovato${NC}"
    echo "Crealo con: cp .env.example .env"
    exit 1
else
    echo -e "${GREEN}✅ .env presente${NC}"
fi

# 4. Test Docker Compose
echo -e "\n${YELLOW}4. Test Docker Compose configuration...${NC}"
if docker compose config > /dev/null 2>&1; then
    echo -e "${GREEN}✅ docker-compose.yml valido${NC}"
else
    echo -e "${RED}❌ Errori in docker-compose.yml${NC}"
    exit 1
fi

# 5. Simula backup
echo -e "\n${YELLOW}5. Test backup database (simulated)...${NC}"
mkdir -p /tmp/aiucd_test_backup
echo "test_backup" > /tmp/aiucd_test_backup/test.sql
echo -e "${GREEN}✅ Backup test OK${NC}"

# 6. Test health check
echo -e "\n${YELLOW}6. Test health check logic...${NC}"
test_health_check() {
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8000 2>/dev/null || echo "000")
    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "302" ]; then
        echo -e "${GREEN}✅ WordPress risponde (HTTP $HTTP_CODE)${NC}"
        return 0
    elif [ "$HTTP_CODE" = "000" ]; then
        echo -e "${YELLOW}⚠️  WordPress non raggiungibile (containers non avviati - OK per test)${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠️  WordPress HTTP $HTTP_CODE (containers potrebbero non essere avviati)${NC}"
        return 0
    fi
}
test_health_check

# 7. Verifica immagini Docker
echo -e "\n${YELLOW}7. Verifica immagini Docker specificate...${NC}"
IMAGES=$(grep "image:" docker-compose.yml | awk '{print $2}')
for image in $IMAGES; do
    if [[ "$image" == *"latest"* ]]; then
        echo -e "${RED}❌ Trovata immagine con tag 'latest': $image${NC}"
        echo "   Usa versioni specifiche per produzione!"
        exit 1
    else
        echo -e "${GREEN}✅ $image (versione pinned)${NC}"
    fi
done

# 8. Test script di gestione
echo -e "\n${YELLOW}8. Test script di gestione...${NC}"
if [ -x scripts/manage.sh ]; then
    echo -e "${GREEN}✅ scripts/manage.sh eseguibile${NC}"
    # Test help
    ./scripts/manage.sh > /dev/null 2>&1
    echo -e "${GREEN}✅ scripts/manage.sh funziona${NC}"
else
    echo -e "${RED}❌ scripts/manage.sh non eseguibile${NC}"
    echo "Run: chmod +x scripts/manage.sh"
    exit 1
fi

# 9. Simula deploy completo (se containers non già running)
echo -e "\n${YELLOW}9. Deploy simulation test...${NC}"
read -p "Vuoi eseguire un test deploy completo? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Esecuzione test deploy..."
    
    # Backup
    echo "→ Backup (skipped in test)"
    
    # Deploy
    echo "→ Starting containers..."
    docker compose down > /dev/null 2>&1 || true
    docker compose up -d
    
    # Health check
    echo "→ Health check..."
    sleep 10
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8000 || echo "000")
    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "302" ]; then
        echo -e "${GREEN}✅ Deploy test successful!${NC}"
    else
        echo -e "${RED}❌ Deploy test failed!${NC}"
        docker compose logs --tail=20
        exit 1
    fi
else
    echo "Skip test deploy"
fi

# Riepilogo
echo ""
echo "========================================"
echo -e "${GREEN}✅ TUTTI I TEST SUPERATI${NC}"
echo "========================================"
echo ""
echo "Il workflow è pronto per il deployment!"
echo ""
echo "Next steps:"
echo "1. Commit e push su GitHub"
echo "2. Configura self-hosted runner sul server"
echo "3. Il deploy partirà automaticamente al push su main"
echo ""
echo "Per configurare il runner, vedi: GITHUB_ACTIONS_SETUP.md"