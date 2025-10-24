📄 README.md — versión resumida para GitHub
# 🖥️ system_info_app..24a


Aplicación web simple construida con **Python + Flask** para mostrar información del sistema donde se ejecuta.

## 🚀 ¿Qué muestra?

- 🧾 Hostname
- 🌐 Dirección IP local
- 💻 Versión del sistema operativo
- 🐍 Versión de Python
- 🕒 Fecha y hora actuales

## 🐳 Docker Ready

Esta app está dockerizada para desarrollo y preparada para despliegue en **Kubernetes**.

### ▶️ Ejecutar en local con Docker Compose

```bash
docker-compose up --build


Accede en tu navegador: http://localhost:5000

🛠️ Usar Makefile (opcional)
make up       # Levanta la app
make down     # Detiene contenedores
make logs     # Muestra logs
make clean    # Limpia imagen y contenedores

📁 Estructura del proyecto
system_info_app/
├── app.py
├── Dockerfile
├── docker-compose.yml
├── Makefile
├── requirements.txt
└── templates/
    └── index.html

☁️ Preparado para Kubernetes

Puedes construir la imagen y subirla a Docker Hub o GitHub Container Registry

Luego usar archivos YAML (Deployment, Service) para desplegarla

👨‍💻 Autor

Desarrollado por [Tu Nombre]
🔗 [Tu GitHub o LinkedIn]