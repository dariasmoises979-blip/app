# Variables de configuración
APP_NAME := system-info-app
IMAGE_NAME := system-info-app
CONTAINER_NAME := $(APP_NAME)-web
COMPOSE_FILE := docker-compose.yml
DOCKER_COMPOSE := docker compose -f $(COMPOSE_FILE)
PORT := 5000

# Colores para output
COLOR_RESET := \033[0m
COLOR_BOLD := \033[1m
COLOR_GREEN := \033[32m
COLOR_YELLOW := \033[33m
COLOR_BLUE := \033[34m
COLOR_RED := \033[31m

# Detección de sistema operativo
ifeq ($(OS),Windows_NT)
    DETECTED_OS := Windows
else
    DETECTED_OS := $(shell uname -s)
endif

.DEFAULT_GOAL := help
.PHONY: help build up down restart logs shell clean test status rebuild stats backup restore check-docker install dev prod clean-orphans images prune

# ==================== AYUDA ====================
help:
	@echo "$(COLOR_BOLD)$(COLOR_BLUE)🐳 $(APP_NAME) - Comandos Docker$(COLOR_RESET)"
	@echo ""
	@echo "$(COLOR_BOLD)📦 Gestión de contenedores:$(COLOR_RESET)"
	@echo "  $(COLOR_GREEN)make build$(COLOR_RESET)       - Construye la imagen Docker"
	@echo "  $(COLOR_GREEN)make up$(COLOR_RESET)          - Levanta servicios en background"
	@echo "  $(COLOR_GREEN)make down$(COLOR_RESET)        - Detiene y elimina contenedores"
	@echo "  $(COLOR_GREEN)make restart$(COLOR_RESET)     - Reinicia todos los servicios"
	@echo "  $(COLOR_GREEN)make rebuild$(COLOR_RESET)     - Reconstruye sin caché"
	@echo ""
	@echo "$(COLOR_BOLD)🔍 Monitoreo y debugging:$(COLOR_RESET)"
	@echo "  $(COLOR_GREEN)make logs$(COLOR_RESET)        - Ver logs en tiempo real"
	@echo "  $(COLOR_GREEN)make shell$(COLOR_RESET)       - Abrir bash en el contenedor"
	@echo "  $(COLOR_GREEN)make status$(COLOR_RESET)      - Estado de contenedores"
	@echo "  $(COLOR_GREEN)make stats$(COLOR_RESET)       - Uso de recursos"
	@echo ""
	@echo "$(COLOR_BOLD)🧪 Testing y calidad:$(COLOR_RESET)"
	@echo "  $(COLOR_GREEN)make test$(COLOR_RESET)        - Ejecutar suite de tests"
	@echo "  $(COLOR_GREEN)make check-docker$(COLOR_RESET) - Verificar Docker instalado"
	@echo ""
	@echo "$(COLOR_BOLD)🧹 Mantenimiento:$(COLOR_RESET)"
	@echo "  $(COLOR_GREEN)make clean$(COLOR_RESET)       - Limpieza completa"
	@echo "  $(COLOR_GREEN)make clean-orphans$(COLOR_RESET) - Eliminar contenedores huérfanos"
	@echo "  $(COLOR_GREEN)make backup$(COLOR_RESET)      - Respaldar volúmenes"
	@echo "  $(COLOR_GREEN)make restore$(COLOR_RESET)     - Restaurar desde backup"
	@echo ""
	@echo "$(COLOR_BOLD)🚀 Entornos:$(COLOR_RESET)"
	@echo "  $(COLOR_GREEN)make dev$(COLOR_RESET)         - Modo desarrollo (con hot-reload)"
	@echo "  $(COLOR_GREEN)make prod$(COLOR_RESET)        - Modo producción"
	@echo ""
	@echo "$(COLOR_BOLD)📍 Info:$(COLOR_RESET)"
	@echo "  URL:        $(COLOR_YELLOW)http://localhost:$(PORT)$(COLOR_RESET)"
	@echo "  OS:         $(DETECTED_OS)"
	@echo "  Compose:    $(COMPOSE_FILE)"
	@echo ""

# ==================== VERIFICACIONES ====================
check-docker:
	@echo "$(COLOR_BLUE)🔍 Verificando Docker...$(COLOR_RESET)"
	@command -v docker >/dev/null 2>&1 || { echo "$(COLOR_RED)❌ Docker no está instalado$(COLOR_RESET)"; exit 1; }
	@docker info >/dev/null 2>&1 || { echo "$(COLOR_RED)❌ Docker daemon no está corriendo$(COLOR_RESET)"; exit 1; }
	@command -v docker compose >/dev/null 2>&1 || command -v docker-compose >/dev/null 2>&1 || { echo "$(COLOR_RED)❌ Docker Compose no está instalado$(COLOR_RESET)"; exit 1; }
	@echo "$(COLOR_GREEN)✅ Docker está listo$(COLOR_RESET)"

# ==================== CONSTRUCCIÓN ====================
build: check-docker
	@echo "$(COLOR_BLUE)🔨 Construyendo imagen $(IMAGE_NAME)...$(COLOR_RESET)"
	@$(DOCKER_COMPOSE) build --progress=plain
	@echo "$(COLOR_GREEN)✅ Imagen construida exitosamente$(COLOR_RESET)"

rebuild: check-docker
	@echo "$(COLOR_BLUE)🔨 Reconstruyendo desde cero (sin caché)...$(COLOR_RESET)"
	@$(DOCKER_COMPOSE) build --no-cache --pull
	@echo "$(COLOR_GREEN)✅ Reconstrucción completada$(COLOR_RESET)"

# ==================== GESTIÓN DE SERVICIOS ====================
up: check-docker
	@echo "$(COLOR_BLUE)🚀 Levantando aplicación...$(COLOR_RESET)"
	@$(DOCKER_COMPOSE) up -d --remove-orphans
	@sleep 2
	@echo "$(COLOR_GREEN)✅ Aplicación corriendo en http://localhost:$(PORT)$(COLOR_RESET)"
	@$(MAKE) --no-print-directory status

down:
	@echo "$(COLOR_YELLOW)🛑 Deteniendo contenedores...$(COLOR_RESET)"
	@$(DOCKER_COMPOSE) down --remove-orphans
	@echo "$(COLOR_GREEN)✅ Contenedores detenidos$(COLOR_RESET)"

restart: down
	@echo "$(COLOR_BLUE)♻️  Reiniciando servicios...$(COLOR_RESET)"
	@$(MAKE) --no-print-directory up

dev: check-docker
	@echo "$(COLOR_BLUE)🔧 Iniciando en modo DESARROLLO...$(COLOR_RESET)"
	@$(DOCKER_COMPOSE) up --build
	
prod: check-docker build
	@echo "$(COLOR_BLUE)🚀 Iniciando en modo PRODUCCIÓN...$(COLOR_RESET)"
	@$(DOCKER_COMPOSE) up -d
	@echo "$(COLOR_GREEN)✅ Producción activa$(COLOR_RESET)"

# ==================== MONITOREO ====================
logs:
	@echo "$(COLOR_BLUE)📋 Logs en tiempo real (Ctrl+C para salir)...$(COLOR_RESET)"
	@$(DOCKER_COMPOSE) logs -f --tail=100

status:
	@echo "$(COLOR_BLUE)📊 Estado de contenedores:$(COLOR_RESET)"
	@docker ps -a --filter "name=$(APP_NAME)" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

stats:
	@echo "$(COLOR_BLUE)📈 Uso de recursos:$(COLOR_RESET)"
	@docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}" $$(docker ps -q --filter "name=$(APP_NAME)")

shell:
	@echo "$(COLOR_BLUE)🐚 Abriendo shell en contenedor...$(COLOR_RESET)"
	@$(DOCKER_COMPOSE) exec web bash || $(DOCKER_COMPOSE) exec web sh

# ==================== TESTING ====================
test:
	@echo "$(COLOR_BLUE)🧪 Ejecutando tests...$(COLOR_RESET)"
	@$(DOCKER_COMPOSE) exec -T web python -m pytest -v --color=yes || echo "$(COLOR_RED)❌ Tests fallidos$(COLOR_RESET)"

# ==================== MANTENIMIENTO ====================
clean:
	@echo "$(COLOR_YELLOW)🧹 Iniciando limpieza profunda...$(COLOR_RESET)"
	@$(DOCKER_COMPOSE) down --volumes --remove-orphans
	@docker image rm $(IMAGE_NAME):latest 2>/dev/null || true
	@docker system prune -f 2>/dev/null || true
	@echo "$(COLOR_GREEN)✅ Limpieza completada$(COLOR_RESET)"

backup:
	@echo "$(COLOR_BLUE)💾 Creando backup de volúmenes...$(COLOR_RESET)"
	@mkdir -p backups
	@docker run --rm \
		-v $(APP_NAME)_data:/data:ro \
		-v $(PWD)/backups:/backup \
		alpine tar czf /backup/backup-$(shell date +%Y%m%d-%H%M%S).tar.gz -C / data
	@echo "$(COLOR_GREEN)✅ Backup creado en ./backups/$(COLOR_RESET)"

restore:
	@echo "$(COLOR_YELLOW)📥 Restaurando desde backup...$(COLOR_RESET)"
	@if [ ! -f "$(BACKUP_FILE)" ]; then \
		echo "$(COLOR_RED)❌ Especifica BACKUP_FILE=ruta/al/backup.tar.gz$(COLOR_RESET)"; \
		exit 1; \
	fi
	@docker run --rm \
		-v $(APP_NAME)_data:/data \
		-v $(PWD)/backups:/backup \
		alpine tar xzf /backup/$(notdir $(BACKUP_FILE)) -C /
	@echo "$(COLOR_GREEN)✅ Restauración completada$(COLOR_RESET)"

# ==================== UTILIDADES ====================
install: check-docker build up
	@echo "$(COLOR_GREEN)🎉 Instalación completa!$(COLOR_RESET)"

# Limpiar contenedores huérfanos
clean-orphans:
	@echo "$(COLOR_YELLOW)🧹 Eliminando contenedores huérfanos...$(COLOR_RESET)"
	@docker ps -a --filter "status=exited" --filter "name=$(APP_NAME)" -q | xargs -r docker rm 2>/dev/null || true
	@docker ps -a --filter "name=local_web" -q | xargs -r docker rm -f 2>/dev/null || true
	@docker network prune -f
	@echo "$(COLOR_GREEN)✅ Huérfanos eliminados$(COLOR_RESET)"

# Ver todas las imágenes relacionadas
images:
	@docker images --filter "reference=$(IMAGE_NAME)"

# Eliminar imágenes huérfanas
prune:
	@echo "$(COLOR_YELLOW)🗑️  Eliminando recursos no utilizados...$(COLOR_RESET)"
	@docker system prune -af --volumes
	@echo "$(COLOR_GREEN)✅ Sistema limpio$(COLOR_RESET)"