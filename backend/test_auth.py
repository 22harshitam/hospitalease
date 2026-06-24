import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_auth_endpoint():
    """Test the authentication test endpoint"""
    response = client.post("/api/auth/test")
    assert response.status_code == 200
    data = response.json()
    assert data["message"] == "Authentication endpoint is working"

def test_login_with_invalid_credentials():
    """Test login with invalid credentials"""
    response = client.post(
        "/api/auth/login-json",
        json={"email": "invalid@test.com", "password": "wrongpassword"}
    )
    assert response.status_code == 401
    assert "Incorrect email or password" in response.json()["detail"]

def test_login_form():
    """Test OAuth2 password form login"""
    response = client.post(
        "/api/auth/login",
        data={"username": "test@test.com", "password": "testpassword"}
    )
    # Should fail since user doesn't exist yet
    assert response.status_code == 401

def test_protected_endpoint_without_token():
    """Test accessing protected endpoint without token"""
    response = client.get("/api/auth/me")
    assert response.status_code == 401

if __name__ == "__main__":
    print("Running authentication tests...")
    test_auth_endpoint()
    print("✓ Auth test endpoint working")
    
    test_login_with_invalid_credentials()
    print("✓ Invalid credentials properly rejected")
    
    test_login_form()
    print("✓ Form login endpoint responding")
    
    test_protected_endpoint_without_token()
    print("✓ Protected endpoints require authentication")
    
    print("\nAll authentication tests passed!")
