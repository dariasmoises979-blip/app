import pytest
from unittest.mock import patch
from app import app

@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

@patch('socket.gethostname', return_value='mock-host')
@patch('socket.gethostbyname', return_value='127.0.0.1')
@patch('platform.platform', return_value='MockOS 1.0')
@patch('platform.python_version', return_value='3.12.0')
@patch('app.datetime')
def test_index_route(mock_datetime, mock_pyver, mock_os, mock_ip, mock_host, client):
    """Prueba completa del endpoint '/' con mocks."""
    mock_datetime.now.return_value.strftime.return_value = '2025-01-01 12:00:00'

    response = client.get('/')
    html = response.data.decode('utf-8')

    assert response.status_code == 200
    assert 'mock-host' in html
    assert '127.0.0.1' in html
    assert 'MockOS 1.0' in html
    assert '3.12.0' in html
    assert '2025-01-01 12:00:00' in html
