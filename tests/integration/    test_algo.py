# tests/integration/test_algo.py

def test_suma_basica():
    """Prueba sencilla: verifica que la suma funciona correctamente."""
    a = 2
    b = 3
    resultado = a + b
    assert resultado == 5, f"Se esperaba 5, pero se obtuvo {resultado}"
