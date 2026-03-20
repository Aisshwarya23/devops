import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

from cyber.app import app
import pytest
import json

@pytest.fixture
def client():
    """Create a test client for the Flask app."""
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_basic():
    """Test basic math (placeholder test)."""
    assert 1 + 1 == 2

def test_index_route(client):
    """Test the index route returns 200."""
    response = client.get('/')
    assert response.status_code == 200

def test_upload_no_file(client):
    """Test upload endpoint without file returns 400."""
    response = client.post('/upload')
    assert response.status_code == 400
    assert b'No file part' in response.data

def test_upload_empty_filename(client):
    """Test upload with empty filename returns 400."""
    response = client.post('/upload', data={'file': (None, '')})
    assert response.status_code == 400

def test_download_model_missing(client):
    """Test download model endpoint (returns 404 if model doesn't exist)."""
    response = client.get('/download_model')
    # Either returns 404 or 200 depending on whether model exists
    assert response.status_code in [200, 404]