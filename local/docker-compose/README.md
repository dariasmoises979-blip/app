# 🚀 Entorno de Desarrollo para Microservicios

Entorno completo de desarrollo local con todas las herramientas necesarias para trabajar con arquitectura de microservicios.

## 📋 Tabla de Contenidos

- [Requisitos Previos](#requisitos-previos)
- [Instalación Rápida](#instalación-rápida)
- [Servicios Incluidos](#servicios-incluidos)
- [Configuración](#configuración)
- [Uso Básico](#uso-básico)
- [Accesos y Credenciales](#accesos-y-credenciales)
- [Comandos Útiles](#comandos-útiles)
- [Estructura de Directorios](#estructura-de-directorios)
- [Troubleshooting](#troubleshooting)

## 🔧 Requisitos Previos

- Docker Engine 20.10 o superior
- Docker Compose 2.0 o superior
- Al menos 8GB de RAM disponible
- 20GB de espacio en disco

## ⚡ Instalación Rápida

### Opción 1: Script Automático (Recomendado)

```bash
# Dar permisos de ejecución
chmod +x setup.sh

# Ejecutar el script de instalación
./setup.sh
```

### Opción 2: Manual

```bash
# 1. Crear estructura de directorios
mkdir -p docker-volumes/{postgres-init,mysql-init,mongo-init,nginx/html,prometheus,grafana/provisioning}

# 2. Copiar archivos de configuración
# - Copiar init.sql a docker-volumes/postgres-init/
# - Copiar init.sql a docker-volumes/mysql-init/
# - Copiar init.js a docker-volumes/mongo-init/
# - Copiar nginx.conf a docker-volumes/nginx/
# - Copiar prometheus.yml a docker-volumes/prometheus/

# 3. Iniciar servicios
docker-compose up -d

# 4. Verificar estado
docker-compose ps
```

## 📦 Servicios Incluidos

### Bases de Datos

| Servicio | Puerto | Descripción |
|----------|--------|-------------|
| PostgreSQL | 5432 | Base de datos relacional principal |
| MySQL | 3306 | Base de datos para servicios legacy |
| MongoDB | 27017 | Base de datos NoSQL para datos no estructurados |
| Redis | 6379 | Cache en memoria y almacén de sesiones |

### Message Brokers

| Servicio | Puerto | UI |
|----------|--------|-----|
| RabbitMQ | 5672 | http://localhost:15672 |
| Kafka | 9092 | http://localhost:8080 |

### Herramientas de Desarrollo

| Servicio | Puerto | Descripción |
|----------|--------|-------------|
| Adminer | 8081 | Cliente universal de bases de datos |
| Mongo Express | 8082 | UI para MongoDB |
| RedisInsight | 5540 | Cliente oficial de Redis |
| Mailhog | 8025 | Servidor SMTP de prueba |
| Swagger Editor | 8083 | Editor de especificaciones OpenAPI |
| MinIO | 9001 | Almacenamiento S3 compatible |

### Monitoreo y Observabilidad

| Servicio | Puerto | Descripción |
|----------|--------|-------------|
| Prometheus | 9090 | Sistema de métricas |
| Grafana | 3000 | Dashboards y visualización |
| Jaeger | 16686 | Distributed tracing |

### Utilidades

| Servicio | Puerto | Descripción |
|----------|--------|-------------|
| Nginx | 80 | API Gateway / Reverse Proxy |
| Portainer | 9000 | Gestión de contenedores |

## ⚙️ Configuración

### Variables de Entorno

Puedes personalizar las credenciales editando el archivo `.env`:

```env
# PostgreSQL
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DB=dev_db

# MySQL
MYSQL_ROOT_PASSWORD=root
MYSQL_DATABASE=dev_db

# Grafana
GRAFANA_ADMIN_USER=admin
GRAFANA_ADMIN_PASSWORD=admin
```

### Nginx API Gateway

El archivo `docker-volumes/nginx/nginx.conf` incluye configuración de ejemplo para enrutar peticiones a tus microservicios:

```
/api/users    -> http://localhost:3001
/api/orders   -> http://localhost:3002
/api/products -> http://localhost:3003
/api/payments -> http://localhost:3004
```

## 🎯 Uso Básico

### Iniciar todos los servicios

```bash
docker-compose up -d
```

### Iniciar servicios específicos

```bash
# Solo bases de datos
docker-compose up -d postgres mysql mongodb redis

# Solo message brokers
docker-compose up -d rabbitmq kafka

# Solo monitoreo
docker-compose up -d prometheus grafana jaeger
```

### Ver logs

```bash
# Todos los servicios
docker-compose logs -f

# Un servicio específico
docker-compose logs -f postgres

# Últimas 100 líneas
docker-compose logs --tail=100 -f
```

### Detener servicios

```bash
# Detener todo
docker-compose down

# Detener y eliminar volúmenes (CUIDADO: borra datos)
docker-compose down -v

# Detener un servicio específico
docker-compose stop postgres
```

### Reiniciar servicios

```bash
# Reiniciar todo
docker-compose restart

# Reiniciar servicio específico
docker-compose restart postgres
```

## 🔑 Accesos y Credenciales

### Bases de Datos

**PostgreSQL**
- Host: `localhost:5432`
- Usuario: `postgres`
- Password: `postgres`
- Base de datos: `dev_db`

**MySQL**
- Host: `localhost:3306`
- Usuario: `root`
- Password: `root`
- Base de datos: `dev_db`

**MongoDB**
- Host: `localhost:27017`
- Sin autenticación para desarrollo

**Redis**
- Host: `localhost:6379`
- Sin password

### Interfaces Web

| Servicio | URL | Credenciales |
|----------|-----|--------------|
| Adminer | http://localhost:8081 | - |
| Mongo Express | http://localhost:8082 | - |
| RedisInsight | http://localhost:5540 | - |
| RabbitMQ | http://localhost:15672 | guest / guest |
| Kafka UI | http://localhost:8080 | - |
| Grafana | http://localhost:3000 | admin / admin |
| Prometheus | http://localhost:9090 | - |
| Jaeger | http://localhost:16686 | - |
| Mailhog | http://localhost:8025 | - |
| MinIO Console | http://localhost:9001 | minioadmin / minioadmin |
| Portainer | http://localhost:9000 | Crear en primer acceso |
| Swagger Editor | http://localhost:8083 | - |

## 💻 Comandos Útiles

### Docker Compose

```bash
# Ver estado de contenedores
docker-compose ps

# Ver uso de recursos
docker stats

# Limpiar contenedores detenidos
docker-compose rm

# Reconstruir imágenes
docker-compose build

# Ver configuración final
docker-compose config
```

### PostgreSQL

```bash
# Conectar con psql
docker exec -it dev_postgres psql -U postgres -d dev_db

# Backup de base de datos
docker exec dev_postgres pg_dump -U postgres dev_db > backup.sql

# Restaurar backup
docker exec -i dev_postgres psql -U postgres dev_db < backup.sql
```

### MySQL

```bash
# Conectar con mysql client
docker exec -it dev_mysql mysql -u root -proot

# Backup de base de datos
docker exec dev_mysql mysqldump -u root -proot dev_db > backup.sql

# Restaurar backup
docker exec -i dev_mysql mysql -u root -proot dev_db < backup.sql
```

### MongoDB

```bash
# Conectar con mongosh
docker exec -it dev_mongo mongosh

# Backup de base de datos
docker exec dev_mongo mongodump --out=/backup

# Restaurar backup
docker exec dev_mongo mongorestore /backup
```

### Redis

```bash
# Conectar con redis-cli
docker exec -it dev_redis redis-cli

# Ver todas las claves
docker exec dev_redis redis-cli KEYS "*"

# Limpiar cache
docker exec dev_redis redis-cli FLUSHALL
```

## 📁 Estructura de Directorios

```
.
├── docker-compose.yml           # Configuración principal
├── setup.sh                     # Script de instalación
├── README.md                    # Esta documentación
├── .env                         # Variables de entorno
└── docker-volumes/
    ├── postgres-init/
    │   └── init.sql            # Script de inicialización PostgreSQL
    ├── mysql-init/
    │   └── init.sql            # Script de inicialización MySQL
    ├── mongo-init/
    │   └── init.js             # Script de inicialización MongoDB
    ├── nginx/
    │   ├── nginx.conf          # Configuración de Nginx
    │   └── html/
    │       └── index.html      # Página de inicio
    ├── prometheus/
    │   └── prometheus.yml      # Configuración de Prometheus
    └── grafana/
        └── provisioning/
            └── datasources/
                └── prometheus.yml  # Datasource de Grafana
```

## 🔧 Troubleshooting

### Puerto ya en uso

```bash
# Ver qué proceso está usando un puerto
lsof -i :5432

# O en Linux
netstat -tulpn | grep 5432

# Matar el proceso
kill -9 <PID>
```

### Contenedor no inicia

```bash
# Ver logs detallados
docker-compose logs <servicio>

# Ver eventos de Docker
docker events

# Inspeccionar contenedor
docker inspect <contenedor>
```

### Limpiar todo y empezar de cero

```bash
# Detener y eliminar todo
docker-compose down -v

# Limpiar imágenes huérfanas
docker image prune -a

# Limpiar volúmenes no usados
docker volume prune

# Reiniciar Docker (si es necesario)
# En Linux: sudo systemctl restart docker
# En Mac/Windows: Reiniciar Docker Desktop
```

### Base de datos no se inicializa

```bash
# Verificar que los scripts están en el lugar correcto
ls -la docker-volumes/postgres-init/
ls -la docker-volumes/mysql-init/
ls -la docker-volumes/mongo-init/

# Eliminar volumen y recrear
docker-compose down -v
docker-compose up -d postgres
```

### Problemas de memoria

```bash
# Aumentar memoria disponible para Docker Desktop
# Settings > Resources > Memory > 8GB+

# Liberar memoria de imágenes no usadas
docker system prune -a --volumes
```

### Servicios lentos

```bash
# Verificar uso de recursos
docker stats

# Reducir servicios activos
docker-compose stop <servicio-no-necesario>

# Asignar más recursos en docker-compose.yml
# (descomentar secciones de deploy/resources)
```

## 📚 Recursos Adicionales

- [Documentación Docker](https://docs.docker.com/)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)
- [PostgreSQL Docs](https://www.postgresql.org/docs/)
- [MongoDB Docs](https://docs.mongodb.com/)
- [Redis Docs](https://redis.io/documentation)
- [RabbitMQ Tutorials](https://www.rabbitmq.com/getstarted.html)

## 🤝 Contribuciones

Si encuentras algún problema o tienes sugerencias de mejora, no dudes en crear un issue o pull request.

## 📄 Licencia

Este proyecto está bajo la licencia MIT.

---

**¡Feliz desarrollo! 🎉**