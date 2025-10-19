import sys
import os
import pytest

# Aseguramos que Flask encuentre app.py
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from app import app

@pytest.fixture
def client():
    """Crea un cliente de pruebas para Flask."""
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_home_status_code(client):
    """Comprueba que la ruta principal responde correctamente."""
    response = client.get('/')
    assert response.status_code == 200

def test_home_content_contains_title(client):
    """Verifica que el HTML contiene el título correcto."""
    response = client.get('/')
    html = response.data.decode('utf-8')
    assert 'Información del Sistema' in html
