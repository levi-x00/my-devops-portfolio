import pytest
from app import app

@pytest.fixture
def client():
    # Create a test client using the Flask application configured for testing
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_home_route(client):
    """Test the home route returns a 200 status code and loads the correct template."""
    response = client.get('/')
    
    # Check that the request was successful (HTTP 200 OK)
    assert response.status_code == 200
    
    # Check that the response contains expected content, e.g., from index.html
    assert b'<html>' in response.data  # Assuming your template has HTML structure
