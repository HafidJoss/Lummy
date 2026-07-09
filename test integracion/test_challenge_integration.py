import pytest
import uuid

@pytest.mark.asyncio
async def test_challenge_integration_flow(async_client):
    # 1. Register and get token
    unique_suffix = str(uuid.uuid4())[:8]
    email = f"challenge_user_{unique_suffix}@example.com"
    password = "SecurePassword123!"
    
    reg_resp = await async_client.post("/api/v1/auth/register", json={
        "email": email,
        "password": password,
        "full_name": "Challenge User"
    })
    assert reg_resp.status_code == 200, f"Failed to register: {reg_resp.text}"
    
    login_resp = await async_client.post("/api/v1/auth/login", json={
        "email": email,
        "password": password
    })
    
    assert login_resp.status_code == 200
    access_token = login_resp.json()["access_token"]
    
    headers = {"Authorization": f"Bearer {access_token}"}
    
    # 2. Start a learning session (challenge)
    # The frontend expects a session response with session_id, questions, etc.
    start_resp = await async_client.post(
        "/api/v1/challenge/start",
        headers=headers
    )
    
    # Normally this hits the Gemini AI API. If it's configured, it should return 201
    assert start_resp.status_code == 201, f"Failed to start challenge: {start_resp.text}"
    start_data = start_resp.json()
    
    # 3. Validate the payload structure
    assert "session_id" in start_data
    assert "questions" in start_data
    assert len(start_data["questions"]) > 0
    
    first_question = start_data["questions"][0]
    assert "session_question_id" in first_question
    assert "stem" in first_question
    assert "options" in first_question
    assert len(first_question["options"]) >= 2
