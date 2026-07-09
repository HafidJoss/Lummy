import requests

def test_get_api_v1_users_me_with_valid_token():
    base_url = "http://localhost:8000"
    login_url = f"{base_url}/api/v1/auth/login"
    user_me_url = f"{base_url}/api/v1/users/me"
    timeout = 30

    # Use valid credentials known to exist on the system
    credentials = {
        "email": "hafapazasulca@gmail.com",
        "password": "hafidcito123"
    }

    try:
        # Step 1: POST to /api/v1/auth/login to get token
        login_response = requests.post(login_url, json=credentials, timeout=timeout)
        assert login_response.status_code == 200, f"Login failed with status {login_response.status_code}"
        login_json = login_response.json()
        assert "access_token" in login_json, "access_token not in login response"
        token = login_json["access_token"]
        assert isinstance(token, str) and token, "access_token is empty or invalid"

        # Step 2: GET to /api/v1/users/me with Authorization Bearer token
        headers = {
            "Authorization": f"Bearer {token}"
        }
        user_response = requests.get(user_me_url, headers=headers, timeout=timeout)
        assert user_response.status_code == 200, f"User profile fetch failed with status {user_response.status_code}"
        user_json = user_response.json()

        # Assert ONLY keys 'id', 'email', 'full_name' are present (no 'username')
        expected_keys = {"id", "email", "full_name"}
        actual_keys = set(user_json.keys())
        missing = expected_keys - actual_keys
        assert not missing, f"Missing keys in user profile response: {missing}"
        # Additional checks for non-empty values
        assert user_json["id"], "User 'id' is empty"
        assert user_json["email"], "User 'email' is empty"
        assert user_json["full_name"], "User 'full_name' is empty"

    except requests.RequestException as e:
        assert False, f"HTTP request failed: {e}"

test_get_api_v1_users_me_with_valid_token()