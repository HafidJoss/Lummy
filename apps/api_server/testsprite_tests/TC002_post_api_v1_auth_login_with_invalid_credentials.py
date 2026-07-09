import requests

def test_post_api_v1_auth_login_with_invalid_credentials():
    base_url = "http://localhost:8000"
    url = f"{base_url}/api/v1/auth/login"
    headers = {"Content-Type": "application/json"}
    # Use invalid email and/or password
    payload = {
        "email": "invalid@example.com",
        "password": "wrongpassword"
    }
    try:
        response = requests.post(url, json=payload, headers=headers, timeout=30)
    except requests.RequestException as e:
        assert False, f"Request failed: {e}"

    # Verify status code is 401 Unauthorized
    assert response.status_code == 401, f"Expected status code 401, got {response.status_code}"

    # Verify no 'access_token' in response JSON
    try:
        response_json = response.json()
    except ValueError:
        response_json = {}

    assert "access_token" not in response_json, "access_token should not be present in response for invalid login"

test_post_api_v1_auth_login_with_invalid_credentials()