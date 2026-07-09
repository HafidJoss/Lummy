import requests

BASE_URL = "http://localhost:8000"
TIMEOUT = 30

def test_get_api_v1_users_me_without_token_or_invalid_token():
    url = f"{BASE_URL}/api/v1/users/me"
    headers_no_token = {}
    headers_invalid_token = {
        "Authorization": "Bearer invalidtoken12345"
    }

    # Test without token
    response_no_token = requests.get(url, headers=headers_no_token, timeout=TIMEOUT)
    assert response_no_token.status_code == 401, f"Expected 401, got {response_no_token.status_code}"
    # Check no user profile data returned (empty or error message expected)
    # Assuming response body should not contain user keys
    no_token_json = {}
    try:
        no_token_json = response_no_token.json()
    except Exception:
        pass
    assert not any(k in no_token_json for k in ["id", "email", "full_name"]), "User data should not be present without token"

    # Test with invalid token
    response_invalid_token = requests.get(url, headers=headers_invalid_token, timeout=TIMEOUT)
    assert response_invalid_token.status_code == 401, f"Expected 401, got {response_invalid_token.status_code}"
    invalid_token_json = {}
    try:
        invalid_token_json = response_invalid_token.json()
    except Exception:
        pass
    assert not any(k in invalid_token_json for k in ["id", "email", "full_name"]), "User data should not be present with invalid token"

test_get_api_v1_users_me_without_token_or_invalid_token()