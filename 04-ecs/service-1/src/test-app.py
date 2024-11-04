import pytest
from app import app

@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_health_check(client):
    """Test the /health route for expected status and content."""
    response = client.get('/health')
    assert response.status_code == 200
    assert response.data == b"OK"