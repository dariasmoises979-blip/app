#!/bin/bash

# ============================================================================
# Script de Instalación del Entorno de Desarrollo
# ============================================================================
# Este script configura todo el entorno necesario para ejecutar el stack
# ============================================================================

set -e  # Salir si hay algún error

echo "🚀 Configurando entorno de desarrollo para microservicios..."
echo ""

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ============================================================================
# Función para imprimir mensajes
# ============================================================================
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# ============================================================================
# Verificar requisitos
# ============================================================================
echo "📋 Verificando requisitos previos..."

if ! command -v docker &> /dev/null; then
    print_error "Docker no está instalado. Por favor instala Docker primero."
    exit 1
fi
print_success "Docker encontrado: $(docker --version)"

if ! command -v docker-compose &> /dev/null; then
    print_error "Docker Compose no está instalado. Por favor instala Docker Compose primero."
    exit 1
fi
print_success "Docker Compose encontrado: $(docker-compose --version)"

echo ""

# ============================================================================
# Crear estructura de directorios
# ============================================================================
echo "📁 Creando estructura de directorios..."

directories=(
    "docker-volumes"
    "docker-volumes/postgres-init"
    "docker-volumes/mysql-init"
    "docker-volumes/mongo-init"
    "docker-volumes/nginx"
    "docker-volumes/nginx/html"
    "docker-volumes/prometheus"
    "docker-volumes/grafana"
    "docker-volumes/grafana/provisioning"
    "docker-volumes/grafana/provisioning/datasources"
    "docker-volumes/grafana/provisioning/dashboards"
    "docker-volumes/portainer"
    "docker-volumes/minio"
    "docker-volumes/redisinsight"
)

for dir in "${directories[@]}"; do
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        print_success "Creado: $dir"
    else
        print_info "Ya existe: $dir"
    fi
done

echo ""

# ============================================================================
# Verificar archivos de configuración
# ============================================================================
echo "📝 Verificando archivos de configuración..."

# Verificar docker-compose.yml
if [ ! -f "docker-compose.yml" ]; then
    print_error "No se encuentra docker-compose.yml"
    exit 1
fi
print_success "docker-compose.yml encontrado"

# Verificar scripts SQL de inicialización
if [ ! -f "docker-volumes/postgres-init/init.sql" ]; then
    print_warning "No se encuentra init.sql de PostgreSQL"
    echo "Por favor, crea el archivo: docker-volumes/postgres-init/init.sql"
else
    print_success "Script de PostgreSQL encontrado"
fi

if [ ! -f "docker-volumes/mysql-init/init.sql" ]; then
    print_warning "No se encuentra init.sql de MySQL"
    echo "Por favor, crea el archivo: docker-volumes/mysql-init/init.sql"
else
    print_success "Script de MySQL encontrado"
fi

if [ ! -f "docker-volumes/mongo-init/init.js" ]; then
    print_warning "No se encuentra init.js de MongoDB"
    echo "Por favor, crea el archivo: docker-volumes/mongo-init/init.js"
else
    print_success "Script de MongoDB encontrado"
fi

echo ""

# ============================================================================
# Crear archivo de Nginx si no existe
# ============================================================================
if [ ! -f "docker-volumes/nginx/nginx.conf" ]; then
    print_info "Creando configuración básica de Nginx..."
    cat > docker-volumes/nginx/nginx.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    server {
        listen 80;
        server_name localhost;

        location / {
            root /usr/share/nginx/html;
            index index.html;
        }

        location /health {
            access_log off;
            return 200 "healthy\n";
            add_header Content-Type text/plain;
        }
    }
}
EOF
    print_success "nginx.conf creado"
fi

# ============================================================================
# Crear archivo HTML de inicio si no existe
# ============================================================================
if [ ! -f "docker-volumes/nginx/html/index.html" ]; then
    print_info "Creando página de inicio..."
    cat > docker-volumes/nginx/html/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Dev Environment</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background: #f5f5f5; }
        h1 { color: #333; }
        .container { background: white; padding: 20px; border-radius: 8px; }
        .service { padding: 10px; margin: 10px 0; background: #e8f4f8; border-radius: 4px; }
        a { color: #0066cc; text-decoration: none; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Entorno de Desarrollo</h1>
        <p>Tu entorno de microservicios está listo</p>
        <div class="service">
            <strong>Adminer:</strong> <a href="http://localhost:8081">http://localhost:8081</a>
        </div>
        <div class="service">
            <strong>Grafana:</strong> <a href="http://localhost:3000">http://localhost:3000</a>
        </div>
        <div class="service">
            <strong>RabbitMQ:</strong> <a href="http://localhost:15672">http://localhost:15672</a>
        </div>
    </div>
</body>
</html>
EOF
    print_success "index.html creado"
fi

# ============================================================================
# Crear configuración de Prometheus si no existe
# ============================================================================
if [ ! -f "docker-volumes/prometheus/prometheus.yml" ]; then
    print_info "Creando configuración de Prometheus..."
    cat > docker-volumes/prometheus/prometheus.yml << 'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
EOF
    print_success "prometheus.yml creado"
fi

# ============================================================================
# Crear configuración de Grafana datasource
# ============================================================================
if [ ! -f "docker-volumes/grafana/provisioning/datasources/prometheus.yml" ]; then
    print_info "Creando datasource de Grafana..."
    cat > docker-volumes/grafana/provisioning/datasources/prometheus.yml << 'EOF'
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://dev_prometheus:9090
    isDefault: true
    editable: true
EOF
    print_success "Grafana datasource creado"
fi

echo ""

# ============================================================================
# Crear archivo .env si no existe
# ============================================================================
if [ ! -f ".env" ]; then
    print_info "Creando archivo .env..."
    cat > .env << 'EOF'
# Configuración de entorno para desarrollo
COMPOSE_PROJECT_NAME=microservices-dev

# PostgreSQL
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DB=dev_db

# MySQL
MYSQL_ROOT_PASSWORD=root
MYSQL_DATABASE=dev_db

# Redis
REDIS_PASSWORD=

# RabbitMQ
RABBITMQ_USER=guest
RABBITMQ_PASSWORD=guest

# Grafana
GRAFANA_ADMIN_USER=admin
GRAFANA_ADMIN_PASSWORD=admin
EOF
    print_success ".env creado"
else
    print_info ".env ya existe"
fi

echo ""

# ============================================================================
# Verificar puertos disponibles
# ============================================================================
echo "🔍 Verificando puertos disponibles..."

ports_to_check=(5432 3306 27017 6379 5672 9092 80 3000 8080 8081 8082 9090)

for port in "${ports_to_check[@]}"; do
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 ; then
        print_warning "Puerto $port ya está en uso"
    fi
done

echo ""

# ============================================================================
# Descargar imágenes Docker
# ============================================================================
echo "📥 Descargando imágenes Docker..."
print_info "Esto puede tardar varios minutos..."

docker-compose pull

print_success "Imágenes descargadas correctamente"
echo ""

# ============================================================================
# Preguntar si iniciar los servicios
# ============================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
print_success "¡Configuración completada!"
echo ""
echo "Para iniciar todos los servicios ejecuta:"
echo "  ${GREEN}docker-compose up -d${NC}"
echo ""
echo "Para ver los logs en tiempo real:"
echo "  ${GREEN}docker-compose logs -f${NC}"
echo ""
echo "Para detener todos los servicios:"
echo "  ${GREEN}docker-compose down${NC}"
echo ""
echo "Para eliminar volúmenes (CUIDADO - borra los datos):"
echo "  ${GREEN}docker-compose down -v${NC}"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

read -p "¿Deseas iniciar los servicios ahora? (s/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]; then
    echo ""
    print_info "Iniciando servicios..."
    docker-compose up -d
    echo ""
    print_success "¡Servicios iniciados correctamente!"
    echo ""
    print_info "Esperando a que los servicios estén listos..."
    sleep 10
    echo ""
    echo "📊 Estado de los contenedores:"
    docker-compose ps
    echo ""
    echo "🌐 Accesos rápidos:"
    echo "  • Nginx:        http://localhost"
    echo "  • Adminer:      http://localhost:8081"
    echo "  • Mongo Express: http://localhost:8082"
    echo "  • RabbitMQ:     http://localhost:15672 (guest/guest)"
    echo "  • Kafka UI:     http://localhost:8080"
    echo "  • Grafana:      http://localhost:3000 (admin/admin)"
    echo "  • Prometheus:   http://localhost:9090"
    echo "  • Jaeger:       http://localhost:16686"
    echo "  • Portainer:    http://localhost:9000"
    echo ""
    print_success "¡Todo listo para desarrollar! 🎉"
fi

echo ""