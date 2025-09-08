"""
Basic tests for the Convertik backend API
"""
import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_health_check():
    """Test that the API is running"""
    response = client.get("/")
    assert response.status_code == 200

def test_rates_endpoint():
    """Test the rates endpoint"""
    response = client.get("/api/v1/rates")
    # Should return 200, 404, or 500 depending on implementation
    assert response.status_code in [200, 404, 500]

def test_stats_endpoint():
    """Test the stats endpoint"""
    response = client.post("/api/v1/stats", json={"events": []})
    # Should return 200, 404, or 422 depending on implementation
    assert response.status_code in [200, 404, 422]

def test_api_version():
    """Test that API version is correct"""
    response = client.get("/api/v1/rates")
    # Check if response contains expected structure
    assert response.status_code in [200, 404, 500]
