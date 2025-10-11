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


#Comando	Acción
#make build	Construye la imagen Docker
#make up	Levanta el contenedor en segundo plano
#make down	Lo detiene y elimina
#make restart	Reinicia todo el stack
#make logs	Muestra logs en tiempo real
#make shell	Entra al contenedor con una shell para depurar
#make clean	Borra contenedor, volumen y la imagen creada
#make help	Muestra la lista de comandos disponibles
