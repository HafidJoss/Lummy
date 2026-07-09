import requests

BASE_URL = "http://localhost:8000"
LOGIN_ENDPOINT = "/api/v1/auth/login"
TIMEOUT = 30

def test_post_api_v1_auth_login_with_valid_credentials():
    url = BASE_URL + LOGIN_ENDPOINT
    headers = {"Content-Type": "application/json"}
    payload = {
        "email": "hafapazasulca@gmail.com",
        "password": "hafidcito123"
    }

    try:
        response = requests.post(url, json=payload, headers=headers, timeout=TIMEOUT)
        response.raise_for_status()
    except requests.RequestException as e:
        assert False, f"Request to login endpoint failed: {e}"

    assert response.status_code == 200, f"Expected status code 200, got {response.status_code}"

    # According to the PRD, response is a string with the token
    response_json = response.json()
    assert "access_token" in response_json, "Response JSON does not contain 'access_token'"

    access_token = response_json["access_token"]
    assert isinstance(access_token, str) and len(access_token) > 0, "'access_token' should be a non-empty string"


test_post_api_v1_auth_login_with_valid_credentials()
