import pytest
import httpx
import os

API_BASE_URL = os.getenv("API_BASE_URL", "http://localhost:8000")

@pytest.fixture
async def async_client():
    async with httpx.AsyncClient(base_url=API_BASE_URL, timeout=30.0) as client:
        yield client
