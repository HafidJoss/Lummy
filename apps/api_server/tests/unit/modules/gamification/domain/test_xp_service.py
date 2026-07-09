import pytest
from unittest.mock import AsyncMock, MagicMock
import uuid
from decimal import Decimal

from apps.api_server.src.modules.gamification.domain.services.xp_service import XPService
from apps.api_server.src.modules.gamification.infrastructure.persistence.models import UserProfile, XpLedger, LevelRule

@pytest.fixture
def mock_session():
    return AsyncMock()

@pytest.fixture
def xp_service(mock_session):
    return XPService(session=mock_session)

@pytest.mark.asyncio
async def test_should_return_level_1_when_no_rules_found(xp_service, mock_session):
    # Arrange
    mock_result = MagicMock()
    mock_result.scalars.return_value.first.return_value = None
    mock_session.execute.return_value = mock_result
    
    # Act
    level = await xp_service.get_level_for_xp(0)
    
    # Assert
    assert level == 1

@pytest.mark.asyncio
async def test_should_return_correct_level_when_rules_exist(xp_service, mock_session):
    # Arrange
    rule = LevelRule(level_id=2, xp_min=100)
    mock_result = MagicMock()
    mock_result.scalars.return_value.first.return_value = rule
    mock_session.execute.return_value = mock_result
    
    # Act
    level = await xp_service.get_level_for_xp(150)
    
    # Assert
    assert level == 2

@pytest.mark.asyncio
async def test_should_return_0_floor_when_no_rule_found(xp_service, mock_session):
    # Arrange
    mock_result = MagicMock()
    mock_result.scalars.return_value.first.return_value = None
    mock_session.execute.return_value = mock_result
    
    # Act
    floor = await xp_service.get_floor_xp(1)
    
    # Assert
    assert floor == 0

@pytest.mark.asyncio
async def test_should_return_correct_floor_xp(xp_service, mock_session):
    # Arrange
    rule = LevelRule(level_id=2, xp_min=100)
    mock_result = MagicMock()
    mock_result.scalars.return_value.first.return_value = rule
    mock_session.execute.return_value = mock_result
    
    # Act
    floor = await xp_service.get_floor_xp(2)
    
    # Assert
    assert floor == 100

@pytest.mark.asyncio
async def test_should_create_profile_if_not_exists(xp_service, mock_session):
    # Arrange
    user_id = uuid.uuid4()
    mock_result = MagicMock()
    mock_result.scalars.return_value.first.return_value = None
    mock_session.execute.return_value = mock_result
    
    # Act
    profile = await xp_service.get_or_create_profile(user_id)
    
    # Assert
    assert profile.user_id == user_id
    assert profile.xp_total == 0
    assert profile.current_level_id == 1
    mock_session.add.assert_called_once()
    mock_session.flush.assert_called_once()

@pytest.mark.asyncio
async def test_should_return_existing_profile(xp_service, mock_session):
    # Arrange
    user_id = uuid.uuid4()
    existing_profile = UserProfile(user_id=user_id, xp_total=50, current_level_id=1)
    mock_result = MagicMock()
    mock_result.scalars.return_value.first.return_value = existing_profile
    mock_session.execute.return_value = mock_result
    
    # Act
    profile = await xp_service.get_or_create_profile(user_id)
    
    # Assert
    assert profile.user_id == user_id
    assert profile.xp_total == 50
    mock_session.add.assert_not_called()

@pytest.mark.asyncio
async def test_should_apply_xp_and_level_up(xp_service, mock_session):
    # Arrange
    user_id = uuid.uuid4()
    session_id = uuid.uuid4()
    existing_profile = UserProfile(
        user_id=user_id, 
        xp_total=80, 
        current_level_id=1,
        total_answered=0,
        total_correct=0
    )
    
    xp_service.get_or_create_profile = AsyncMock(return_value=existing_profile)
    xp_service.get_floor_xp = AsyncMock(return_value=0)
    xp_service.get_level_for_xp = AsyncMock(return_value=2)
    
    # Act
    result = await xp_service.apply_session_xp(
        user_id=user_id,
        xp_gained=25,
        xp_lost=0,
        correct_answers=5,
        total_questions=5,
        challenge_session_id=session_id
    )
    
    # Assert
    assert result['xp_before'] == 80
    assert result['xp_gained'] == 25
    assert result['xp_delta'] == 25
    assert result['xp_after_final'] == 105
    assert result['level_up'] == True
    assert result['floor_applied'] == False
    
    assert existing_profile.xp_total == 105
    assert existing_profile.current_level_id == 2
    assert existing_profile.total_answered == 5
    assert existing_profile.total_correct == 5
    assert existing_profile.accuracy_global == Decimal('100.00')

@pytest.mark.asyncio
async def test_should_not_allow_xp_below_frustration_floor(xp_service, mock_session):
    # Arrange
    user_id = uuid.uuid4()
    session_id = uuid.uuid4()
    existing_profile = UserProfile(
        user_id=user_id, 
        xp_total=105, 
        current_level_id=2,
        total_answered=5,
        total_correct=5
    )
    
    xp_service.get_or_create_profile = AsyncMock(return_value=existing_profile)
    xp_service.get_floor_xp = AsyncMock(return_value=100)
    xp_service.get_level_for_xp = AsyncMock(return_value=2)
    
    # Act
    result = await xp_service.apply_session_xp(
        user_id=user_id,
        xp_gained=0,
        xp_lost=15,
        correct_answers=0,
        total_questions=3,
        challenge_session_id=session_id
    )
    
    # Assert
    assert result['xp_after_raw'] == 90
    assert result['xp_after_floor'] == 100
    assert result['xp_after_final'] == 100
    assert result['floor_applied'] == True
    
    assert existing_profile.xp_total == 100
