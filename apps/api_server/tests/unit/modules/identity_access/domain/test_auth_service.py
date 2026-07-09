import pytest
from unittest.mock import AsyncMock, MagicMock, patch
import uuid
from datetime import datetime, timezone

from apps.api_server.src.modules.identity_access.domain.services.auth_service import AuthService
from apps.api_server.src.modules.identity_access.infrastructure.persistence.models import User
from apps.api_server.src.shared.infrastructure.api.exceptions import APIException
from apps.api_server.src.modules.identity_access.application.dto.auth_dtos import (
    RegisterRequest, LoginRequest, RefreshRequest
)

@pytest.fixture
def mock_session():
    return AsyncMock()

@pytest.fixture
def auth_service(mock_session):
    return AuthService(session=mock_session)

@pytest.mark.asyncio
@patch('apps.api_server.src.modules.identity_access.domain.services.auth_service.get_password_hash')
async def test_should_register_user_successfully(mock_hash, auth_service, mock_session):
    # Arrange
    request = RegisterRequest(email="test@example.com", password="password123", full_name="Test User")
    mock_hash.return_value = "hashed_pw"
    
    async def mock_execute(*args, **kwargs):
        mock_res = MagicMock()
        mock_res.scalars.return_value.first.return_value = None
        return mock_res
    mock_session.execute.side_effect = mock_execute
    
    # Act
    result = await auth_service.register(request)
    
    # Assert
    assert result.email == "test@example.com"
    assert result.password_hash == "hashed_pw"
    assert result.full_name == "Test User"
    assert result.is_active == True
    assert mock_session.add.call_count == 2 # User, UserProfile
    assert mock_session.commit.called
    assert mock_session.refresh.called

@pytest.mark.asyncio
async def test_should_fail_register_when_email_exists(auth_service, mock_session):
    # Arrange
    request = RegisterRequest(email="test@example.com", password="password123", full_name="Test User")
    
    async def mock_execute(*args, **kwargs):
        mock_res = MagicMock()
        mock_res.scalars.return_value.first.return_value = User(id=uuid.uuid4(), email="test@example.com")
        return mock_res
    mock_session.execute.side_effect = mock_execute
    
    # Act & Assert
    with pytest.raises(APIException) as exc:
        await auth_service.register(request)
    assert exc.value.status_code == 400
    assert exc.value.code == "EMAIL_IN_USE"

@pytest.mark.asyncio
@patch('apps.api_server.src.modules.identity_access.domain.services.auth_service.verify_password')
@patch('apps.api_server.src.modules.identity_access.domain.services.auth_service.create_access_token')
@patch('apps.api_server.src.modules.identity_access.domain.services.auth_service.create_refresh_token')
async def test_should_login_user_successfully(mock_create_refresh, mock_create_access, mock_verify, auth_service, mock_session):
    # Arrange
    request = LoginRequest(email="test@example.com", password="password123")
    user = User(id=uuid.uuid4(), email="test@example.com", password_hash="hash", is_active=True)
    
    async def mock_execute(*args, **kwargs):
        mock_res = MagicMock()
        mock_res.scalars.return_value.first.return_value = user
        return mock_res
    mock_session.execute.side_effect = mock_execute
    
    mock_verify.return_value = True
    mock_create_access.return_value = "access_token_123"
    mock_create_refresh.return_value = "refresh_token_123"
    
    # Act
    result = await auth_service.login(request)
    
    # Assert
    assert result.access_token == "access_token_123"
    assert result.refresh_token == "refresh_token_123"
    assert user.last_login_at is not None
    assert mock_session.commit.called

@pytest.mark.asyncio
async def test_should_fail_login_invalid_credentials(auth_service, mock_session):
    # Arrange
    request = LoginRequest(email="test@example.com", password="password123")
    
    async def mock_execute(*args, **kwargs):
        mock_res = MagicMock()
        mock_res.scalars.return_value.first.return_value = None
        return mock_res
    mock_session.execute.side_effect = mock_execute
    
    # Act & Assert
    with pytest.raises(APIException) as exc:
        await auth_service.login(request)
    assert exc.value.status_code == 401
    assert exc.value.code == "INVALID_CREDENTIALS"

@pytest.mark.asyncio
@patch('apps.api_server.src.modules.identity_access.domain.services.auth_service.verify_password')
async def test_should_fail_login_inactive_user(mock_verify, auth_service, mock_session):
    # Arrange
    request = LoginRequest(email="test@example.com", password="password123")
    user = User(id=uuid.uuid4(), email="test@example.com", password_hash="hash", is_active=False)
    
    async def mock_execute(*args, **kwargs):
        mock_res = MagicMock()
        mock_res.scalars.return_value.first.return_value = user
        return mock_res
    mock_session.execute.side_effect = mock_execute
    
    mock_verify.return_value = True
    
    # Act & Assert
    with pytest.raises(APIException) as exc:
        await auth_service.login(request)
    assert exc.value.status_code == 403
    assert exc.value.code == "USER_INACTIVE"

@pytest.mark.asyncio
@patch('apps.api_server.src.modules.identity_access.domain.services.auth_service.decode_token')
@patch('apps.api_server.src.modules.identity_access.domain.services.auth_service.create_access_token')
async def test_should_refresh_token_successfully(mock_create_access, mock_decode, auth_service):
    # Arrange
    request = RefreshRequest(refresh_token="valid_refresh")
    mock_decode.return_value = {"type": "refresh", "sub": "123", "email": "test@example.com"}
    mock_create_access.return_value = "new_access_token"
    
    # Act
    result = await auth_service.refresh_token(request)
    
    # Assert
    assert result.access_token == "new_access_token"

@pytest.mark.asyncio
@patch('apps.api_server.src.modules.identity_access.domain.services.auth_service.decode_token')
async def test_should_fail_refresh_invalid_token(mock_decode, auth_service):
    # Arrange
    request = RefreshRequest(refresh_token="invalid_refresh")
    mock_decode.return_value = None
    
    # Act & Assert
    with pytest.raises(APIException) as exc:
        await auth_service.refresh_token(request)
    assert exc.value.status_code == 401
    assert exc.value.code == "INVALID_TOKEN"

@pytest.mark.asyncio
async def test_should_logout(auth_service):
    await auth_service.logout("123")
    # Just ensures it runs without error
