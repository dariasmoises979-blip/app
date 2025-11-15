# ============================================================================
# MAKEFILE - COMANDOS PARA GESTIÓN DEL ENTORNO
# ============================================================================
# Uso: make <comando>
# Ejemplo: make up
# ============================================================================

.PHONY: help up down restart logs ps clean prune backup restore health check-env

# Variables
COMPOSE_FILE := docker-compose.yml
ENV_FILE := .env
PROJECT_NAME := $(shell grep COMPOSE_PROJECT_NAME .env | cut -d '=' -f2)

# Colores para output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
NC := \033[0m # No Color

# ============================================================================
# COMANDOS PRINCIPALES
# ============================================================================

## help: Muestra esta ayuda
help:
	@echo "$(BLUE)Comandos disponibles:$(NC)"
	@echo ""
	@grep -E '^## ' $(MAKEFILE_LIST) | sed 's/## /  $(GREEN)/g' | sed 's/:/ $(NC)-/g'
	@echo ""

## check-env: Verifica que el archivo .env existe
check-env:
	@if [ ! -f $(ENV_FILE) ]; then \
		echo "$(RED)Error: $(ENV_FILE) no encontrado$(NC)"; \
		echo "$(YELLOW)Copia .env.example a .env y configúralo$(NC)"; \
		exit 1; \
	fi
	@echo "$(GREEN)✓ Archivo .env encontrado$(NC)"

## setup: Configuración inicial del proyecto
setup: check-env
	@echo "$(BLUE)Configurando entorno...$(NC)"
	@chmod +x setup.sh
	@./setup.sh
	@echo "$(GREEN)✓ Configuración completada$(NC)"

# ============================================================================
# GESTIÓN DE CONTENEDORES
# ============================================================================

## up: Inicia todos los servicios
up: check-env
	@echo "$(BLUE)Iniciando servicios...$(NC)"
	docker-compose up -d
	@echo "$(GREEN)✓ Servicios iniciados$(NC)"
	@make ps

## down: Detiene todos los servicios
down:
	@echo "$(BLUE)Deteniendo servicios...$(NC)"
	docker-compose down
	@echo "$(GREEN)✓ Servicios detenidos$(NC)"

## restart: Reinicia todos los servicios
restart:
	@echo "$(BLUE)Reiniciando servicios...$(NC)"
	docker-compose restart
	@echo "$(GREEN)✓ Servicios reiniciados$(NC)"

## stop: Detiene los servicios sin eliminar contenedores
stop:
	@echo "$(BLUE)Deteniendo servicios...$(NC)"
	docker-compose stop
	@echo "$(GREEN)✓ Servicios detenidos$(NC)"

## start: Inicia servicios detenidos
start:
	@echo "$(BLUE)Iniciando servicios detenidos...$(NC)"
	docker-compose start
	@echo "$(GREEN)✓ Servicios iniciados$(NC)"

# ============================================================================
# SERVICIOS ESPECÍFICOS
# ============================================================================

## up-db: Inicia solo las bases de datos
up-db: check-env
	@echo "$(BLUE)Iniciando bases de datos...$(NC)"
	docker-compose up -d postgres mysql mongodb redis
	@echo "$(GREEN)✓ Bases de datos iniciadas$(NC)"

## up-messaging: Inicia solo los message brokers
up-messaging: check-env
	@echo "$(BLUE)Iniciando message brokers...$(NC)"
	docker-compose up -d rabbitmq kafka kafka-ui
	@echo "$(GREEN)✓ Message brokers iniciados$(NC)"

## up-monitoring: Inicia solo servicios de monitoreo
up-monitoring: check-env
	@echo "$(BLUE)Iniciando servicios de monitoreo...$(NC)"
	docker-compose up -d prometheus grafana jaeger
	@echo "$(GREEN)✓ Monitoreo iniciado$(NC)"

## up-tools: Inicia solo herramientas de desarrollo
up-tools: check-env
	@echo "$(BLUE)Iniciando herramientas...$(NC)"
	docker-compose up -d adminer mongo-express redis-insight mailhog portainer
	@echo "$(GREEN)✓ Herramientas iniciadas$(NC)"

# ============================================================================
# MONITOREO Y LOGS
# ============================================================================

## ps: Muestra el estado de los contenedores
ps:
	@docker-compose ps

## logs: Muestra logs de todos los servicios
logs:
	docker-compose logs -f

## logs-postgres: Logs de PostgreSQL
logs-postgres:
	docker-compose logs -f postgres

## logs-mysql: Logs de MySQL
logs-mysql:
	docker-compose logs -f mysql

## logs-mongodb: Logs de MongoDB
logs-mongodb:
	docker-compose logs -f mongodb

## logs-redis: Logs de Redis
logs-redis:
	docker-compose logs -f redis

## logs-nginx: Logs de Nginx
logs-nginx:
	docker-compose logs -f nginx

## health: Verifica el estado de salud de los servicios
health:
	@echo "$(BLUE)Estado de salud de los servicios:$(NC)"
	@docker-compose ps --format json | jq -r '.[] | "\(.Name): \(.Health)"'

## stats: Muestra uso de recursos
stats:
	docker stats --no-stream

# ============================================================================
# BASES DE DATOS
# ============================================================================

## db-postgres: Conecta a PostgreSQL
db-postgres:
	docker exec -it $(PROJECT_NAME)_postgres psql -U postgres -d dev_db

## db-mysql: Conecta a MySQL
db-mysql:
	docker exec -it $(PROJECT_NAME)_mysql mysql -u root -proot

## db-mongodb: Conecta a MongoDB
db-mongodb:
	docker exec -it $(PROJECT_NAME)_mongodb mongosh

## db-redis: Conecta a Redis
db-redis:
	docker exec -it $(PROJECT_NAME)_redis redis-cli

# ============================================================================
# BACKUPS
# ============================================================================

## backup-postgres: Backup de PostgreSQL
backup-postgres:
	@mkdir -p ./backups
	@echo "$(BLUE)Creando backup de PostgreSQL...$(NC)"
	docker exec $(PROJECT_NAME)_postgres pg_dumpall -U postgres > ./backups/postgres-$(shell date +%Y%m%d-%H%M%S).sql
	@echo "$(GREEN)✓ Backup creado en ./backups/$(NC)"

## backup-mysql: Backup de MySQL
backup-mysql:
	@mkdir -p ./backups
	@echo "$(BLUE)Creando backup de MySQL...$(NC)"
	docker exec $(PROJECT_NAME)_mysql mysqldump -u root -proot --all-databases > ./backups/mysql-$(shell date +%Y%m%d-%H%M%S).sql
	@echo "$(GREEN)✓ Backup creado en ./backups/$(NC)"

## backup-mongodb: Backup de MongoDB
backup-mongodb:
	@mkdir -p ./backups
	@echo "$(BLUE)Creando backup de MongoDB...$(NC)"
	docker exec $(PROJECT_NAME)_mongodb mongodump --archive=./backups/mongodb-$(shell date +%Y%m%d-%H%M%S).archive
	@echo "$(GREEN)✓ Backup creado en ./backups/$(NC)"

## backup-all: Backup de todas las bases de datos
backup-all: backup-postgres backup-mysql backup-mongodb
	@echo "$(GREEN)✓ Todos los backups completados$(NC)"

# ============================================================================
# LIMPIEZA
# ============================================================================

## clean: Detiene y elimina contenedores
clean:
	@echo "$(YELLOW)⚠ Deteniendo y eliminando contenedores...$(NC)"
	docker-compose down
	@echo "$(GREEN)✓ Limpieza completada$(NC)"

## clean-volumes: Detiene y elimina contenedores y volúmenes (CUIDADO: borra datos)
clean-volumes:
	@echo "$(RED)⚠ ADVERTENCIA: Esto eliminará TODOS los datos$(NC)"
	@read -p "¿Estás seguro? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker-compose down -v; \
		echo "$(GREEN)✓ Volúmenes eliminados$(NC)"; \
	else \
		echo "$(YELLOW)Operación cancelada$(NC)"; \
	fi

## prune: Limpia recursos Docker no utilizados
prune:
	@echo "$(YELLOW)Limpiando recursos Docker...$(NC)"
	docker system prune -f
	@echo "$(GREEN)✓ Limpieza completada$(NC)"

## prune-all: Limpieza profunda de Docker (CUIDADO)
prune-all:
	@echo "$(RED)⚠ ADVERTENCIA: Limpieza profunda de Docker$(NC)"
	@read -p "¿Estás seguro? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker system prune -a --volumes -f; \
		echo "$(GREEN)✓ Limpieza profunda completada$(NC)"; \
	else \
		echo "$(YELLOW)Operación cancelada$(NC)"; \
	fi

# ============================================================================
# DESARROLLO
# ============================================================================

## build: Reconstruye las imágenes
build:
	@echo "$(BLUE)Reconstruyendo imágenes...$(NC)"
	docker-compose build --no-cache
	@echo "$(GREEN)✓ Imágenes reconstruidas$(NC)"

## pull: Descarga las últimas versiones de las imágenes
pull:
	@echo "$(BLUE)Descargando imágenes...$(NC)"
	docker-compose pull
	@echo "$(GREEN)✓ Imágenes actualizadas$(NC)"

## update: Actualiza y reinicia todos los servicios
update: pull
	@echo "$(BLUE)Actualizando servicios...$(NC)"
	docker-compose up -d --force-recreate
	@echo "$(GREEN)✓ Servicios actualizados$(NC)"

# ============================================================================
# VALIDACIÓN Y TESTING
# ============================================================================

## validate: Valida la configuración de docker-compose
validate:
	@echo "$(BLUE)Validando configuración...$(NC)"
	docker-compose config --quiet
	@echo "$(GREEN)✓ Configuración válida$(NC)"

## test-connections: Prueba conexiones a las bases de datos
test-connections:
	@echo "$(BLUE)Probando conexiones...$(NC)"
	@echo "PostgreSQL:"
	@docker exec $(PROJECT_NAME)_postgres pg_isready -U postgres && echo "$(GREEN)✓ OK$(NC)" || echo "$(RED)✗ FAIL$(NC)"
	@echo "MySQL:"
	@docker exec $(PROJECT_NAME)_mysql mysqladmin ping -u root -proot && echo "$(GREEN)✓ OK$(NC)" || echo "$(RED)✗ FAIL$(NC)"
	@echo "MongoDB:"
	@docker exec $(PROJECT_NAME)_mongodb mongosh --eval "db.adminCommand('ping')" && echo "$(GREEN)✓ OK$(NC)" || echo "$(RED)✗ FAIL$(NC)"
	@echo "Redis:"
	@docker exec $(PROJECT_NAME)_redis redis-cli ping && echo "$(GREEN)✓ OK$(NC)" || echo "$(RED)✗ FAIL$(NC)"

# ============================================================================
# INFORMACIÓN
# ============================================================================

## info: Muestra información del entorno
info:
	@echo "$(BLUE)Información del entorno:$(NC)"
	@echo "Proyecto: $(GREEN)$(PROJECT_NAME)$(NC)"
	@echo "Docker version: $(shell docker --version)"
	@echo "Docker Compose version: $(shell docker-compose --version)"
	@echo ""
	@echo "$(BLUE)URLs de acceso:$(NC)"
	@echo "  • Nginx:          http://localhost"
	@echo "  • Adminer:        http://localhost:8081"
	@echo "  • Mongo Express:  http://localhost:8082"
	@echo "  • RabbitMQ:       http://localhost:15672"
	@echo "  • Kafka UI:       http://localhost:8080"
	@echo "  • Grafana:        http://localhost:3000"
	@echo "  • Prometheus:     http://localhost:9090"
	@echo "  • Jaeger:         http://localhost:16686"
	@echo "  • Portainer:      http://localhost:9000"
	@echo "  • MinIO Console:  http://localhost:9001"

## urls: Muestra las URLs de acceso
urls:
	@echo "$(BLUE)URLs de acceso:$(NC)"
	@echo ""
	@echo "$(YELLOW)Bases de Datos:$(NC)"
	@echo "  PostgreSQL:  localhost:5432"
	@echo "  MySQL:       localhost:3306"
	@echo "  MongoDB:     localhost:27017"
	@echo "  Redis:       localhost:6379"
	@echo ""
	@echo "$(YELLOW)Interfaces Web:$(NC)"
	@echo "  Nginx:          $(GREEN)http://localhost$(NC)"
	@echo "  Adminer:        $(GREEN)http://localhost:8081$(NC)"
	@echo "  Mongo Express:  $(GREEN)http://localhost:8082$(NC)"
	@echo "  Redis Insight:  $(GREEN)http://localhost:5540$(NC)"
	@echo "  RabbitMQ UI:    $(GREEN)http://localhost:15672$(NC) (guest/guest)"
	@echo "  Kafka UI:       $(GREEN)http://localhost:8080$(NC)"
	@echo "  Mailhog:        $(GREEN)http://localhost:8025$(NC)"
	@echo "  Swagger:        $(GREEN)http://localhost:8083$(NC)"
	@echo ""
	@echo "$(YELLOW)Monitoreo:$(NC)"
	@echo "  Grafana:        $(GREEN)http://localhost:3000$(NC) (admin/admin)"
	@echo "  Prometheus:     $(GREEN)http://localhost:9090$(NC)"
	@echo "  Jaeger:         $(GREEN)http://localhost:16686$(NC)"
	@echo ""
	@echo "$(YELLOW)Utilidades:$(NC)"
	@echo "  Portainer:      $(GREEN)http://localhost:9000$(NC)"
	@echo "  MinIO Console:  $(GREEN)http://localhost:9001$(NC) (minioadmin/minioadmin)"

# ============================================================================
# DEFAULT
# ============================================================================

.DEFAULT_GOAL := help