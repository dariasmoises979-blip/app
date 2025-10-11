# Variables
APP_NAME=system_info_app
IMAGE_NAME=system_info_app
DOCKER_COMPOSE=docker-compose
PORT=5000

.PHONY: help build up down restart logs shell clean

help:
	@echo "Comandos disponibles:"
	@echo "  make build       - Construye la imagen Docker"
	@echo "  make up          - Levanta el contenedor con docker-compose"
	@echo "  make down        - Detiene y elimina contenedores"
	@echo "  make restart     - Reinicia el contenedor"
	@echo "  make logs        - Muestra los logs del contenedor"
	@echo "  make shell       - Entra al contenedor en una shell bash"
	@echo "  make clean       - Limpia todo: contenedores, imágenes, volúmenes"

build:
	$(DOCKER_COMPOSE) build

up:
	$(DOCKER_COMPOSE) up -d

down:
	$(DOCKER_COMPOSE) down

restart:
	$(DOCKER_COMPOSE) down
	$(DOCKER_COMPOSE) up -d

logs:
	$(DOCKER_COMPOSE) logs -f

shell:
	$(DOCKER_COMPOSE) exec web bash

clean:
	$(DOCKER_COMPOSE) down --volumes --remove-orphans
	docker image rm $(IMAGE_NAME):latest || true
✅ ¿Qué hace cada comando?
Comando	Acción
make build	Construye la imagen Docker
make up	Levanta el contenedor en segundo plano
make down	Lo detiene y elimina
make restart	Reinicia todo el stack
make logs	Muestra logs en tiempo real
make shell	Entra al contenedor con una shell para depurar
make clean	Borra contenedor, volumen y la imagen creada
make help	Muestra la lista de comandos disponibles

🧪 Uso típico en desarrollo local
bash
Copiar código
make build     # Compila la imagen
make up        # Corre la app
make logs      # Para ver logs
make shell     # Para entrar al contenedor
make down      # Para detenerla
¿Quieres agregar tareas como tests automáticos o despliegue a Kubernetes desde el Makefile también? Te puedo ayudar con eso a continuación.



Tú dijiste:
crea unreadme de todo

ChatGPT Plus
Perfecto. Aquí tienes un README.md profesional y completo para tu proyecto system_info_app, ideal para documentarlo en GitHub, GitLab o cualquier sistema de control de versiones.

📄 README.md
markdown
Copiar código
# 🖥️ system_info_app

Una pequeña aplicación web construida con **Python + Flask** que muestra información del sistema donde se ejecuta, incluyendo:

- Nombre del host (hostname)
- Dirección IP
- Versión del sistema operativo
- Versión de Python
- Fecha y hora actuales

## 📸 Captura de pantalla

![Screenshot](https://via.placeholder.com/800x400?text=System+Info+App)

---

## 🚀 Características

- ✅ Backend en Flask
- ✅ Interfaz web simple con HTML + Bootstrap
- ✅ Dockerizado para desarrollo local
- ✅ Listo para subir a Git y desplegar en Kubernetes
- ✅ Makefile para automatización de tareas

---

## 📁 Estructura del Proyecto

system_info_app/
├── app.py # Aplicación Flask principal
├── requirements.txt # Dependencias de Python
├── Dockerfile # Imagen Docker personalizada
├── docker-compose.yml # Orquestador de contenedores para desarrollo
├── Makefile # Comandos útiles para desarrollo local
├── templates/
│ └── index.html # Plantilla HTML

yaml
Copiar código

---

## ⚙️ Requisitos

- [Python 3.11+](https://www.python.org/)
- [Docker](https://www.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)
- [Make](https://www.gnu.org/software/make/) (opcional pero recomendado)

---

## 🧪 Uso en Desarrollo Local

### 🔧 Paso 1: Clonar el proyecto

```bash
git clone https://github.com/tuusuario/system_info_app.git
cd system_info_app
🐳 Paso 2: Levantar la app con Docker
bash
Copiar código
make build   # Construye la imagen Docker
make up      # Levanta el contenedor en segundo plano
Visita 👉 http://localhost:5000

📜 Ver logs
bash
Copiar código
make logs
🛠️ Entrar al contenedor
bash
Copiar código
make shell
🧹 Limpiar contenedores, volúmenes e imagen
bash
Copiar código
make clean
☁️ Despliegue en Kubernetes (K8s)
🛠️ A implementar. Se recomienda subir la imagen Docker a Docker Hub o GitHub Container Registry, luego usar un manifiesto Kubernetes con Deployment y Service.

Pasos generales:

Construir y subir la imagen:

bash
Copiar código
docker build -t tuusuario/system_info_app:latest .
docker push tuusuario/system_info_app:latest
Crear los archivos YAML (deployment.yaml, service.yaml, etc.)

Desplegar en tu clúster con kubectl apply -f.

¿Quieres que esos YAML estén listos aquí? Te los puedo generar.

📦 Dependencias
nginx
Copiar código
flask
Instalables manualmente con:

bash
Copiar código
pip install -r requirements.txt
👨‍💻 Autor
Desarrollado por [Tu Nombre] · [tu@email.com] · [@tu_usuario]
