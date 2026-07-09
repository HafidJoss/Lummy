import pytest
import uuid

@pytest.mark.asyncio
async def test_auth_integration_flow(async_client):
    # 1. Register a new user
    unique_suffix = str(uuid.uuid4())[:8]
    email = f"test_integration_{unique_suffix}@example.com"
    password = "SecurePassword123!"
    
    register_payload = {
        "email": email,
        "password": password,
        "full_name": f"IntegrationUser_{unique_suffix}"
    }
    
    reg_response = await async_client.post("/api/v1/auth/register", json=register_payload)
    assert reg_response.status_code == 200, f"Failed to register: {reg_response.text}"
    reg_data = reg_response.json()
    assert "id" in reg_data
    
    # 2. Login with the registered user
    # FastAPI's OAuth2PasswordRequestForm expects form data (x-www-form-urlencoded)
    login_payload = {
        "email": email,
        "password": password
    }
    
    login_response = await async_client.post("/api/v1/auth/login", json=login_payload)
    assert login_response.status_code == 200, f"Failed to login: {login_response.text}"
    login_data = login_response.json()
    assert "access_token" in login_data
    assert login_data["token_type"] == "bearer"
    
    access_token = login_data["access_token"]
    
    # 3. Access a protected endpoint (e.g. /api/v1/users/me)
    headers = {
        "Authorization": f"Bearer {access_token}"
    }
    me_response = await async_client.get("/api/v1/users/me", headers=headers)
    assert me_response.status_code == 200, f"Failed to get user profile: {me_response.text}"
    me_data = me_response.json()
    
    assert me_data["email"] == email
    assert me_data["full_name"] == register_payload["full_name"]
