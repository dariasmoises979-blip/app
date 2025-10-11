# Variables
APP_NAME=system-info-app
IMAGE_NAME=system-info-app
DOCKER_COMPOSE=docker-compose -f docker-compose.yml
PORT=5000

.PHONY: help build up down restart logs shell clean test

help:
	@echo "🐳 $(APP_NAME) - Comandos Docker"
	@echo ""
	@echo "  make build       - Construye la imagen"
	@echo "  make up          - Levanta en background"
	@echo "  make down        - Detiene contenedores"
	@echo "  make restart     - Reinicia todo"
	@echo "  make logs        - Ver logs en tiempo real"
	@echo "  make shell       - Bash dentro del contenedor"
	@echo "  make clean       - Limpieza total"
	@echo "  make test        - Ejecutar tests"
	@echo ""
	@echo "📍 URL: http://localhost:$(PORT)"

build:
	@echo "🔨 Construyendo imagen..."
	$(DOCKER_COMPOSE) build

up:
	@echo "🚀 Levantando aplicación..."
	$(DOCKER_COMPOSE) up -d
	@echo "✅ Listo en http://localhost:$(PORT)"

down:
	@echo "🛑 Deteniendo contenedores..."
	$(DOCKER_COMPOSE) down

restart: down up
	@echo "♻️  Aplicación reiniciada"

logs:
	@echo "📋 Mostrando logs (Ctrl+C para salir)..."
	$(DOCKER_COMPOSE) logs -f

shell:
	@echo "🐚 Entrando al contenedor..."
	$(DOCKER_COMPOSE) exec web bash

clean:
	@echo "🧹 Limpieza profunda..."
	$(DOCKER_COMPOSE) down --volumes --remove-orphans
	docker image rm $(IMAGE_NAME):latest 2>/dev/null || true
	@echo "✅ Limpieza completada"

test:
	@echo "🧪 Ejecutando tests..."
	$(DOCKER_COMPOSE) exec web python -m pytest

# Ver estado de contenedores
status:
	@docker ps --filter "name=$(APP_NAME)"

# Reconstruir sin caché
rebuild:
	$(DOCKER_COMPOSE) build --no-cache

# Ver uso de recursos
stats:
	docker stats --no-stream

# Backup de volúmenes
backup:
	docker run --rm -v $(APP_NAME)_data:/data -v $(PWD):/backup \
		ubuntu tar czf /backup/backup.tar.gz /data

# Comando por defecto
#.DEFAULT_GOAL := help

# Sin argumentos muestra ayuda
#$ make

# Flujo de desarrollo normal
#$ make build          # Primera vez
#$ make up             # Levantar
#$ make logs           # Ver qué pasa
#$ make shell          # Entrar si hay problema
#$ make restart        # Aplicar cambios

# Al terminar
#$ make down           # Parar
#$ make clean          # Limpiar todo