import pytest
from unittest.mock import AsyncMock, MagicMock, patch
import uuid
from decimal import Decimal

from apps.api_server.src.modules.learning_session.domain.services.challenge_service import ChallengeService
from apps.api_server.src.modules.gamification.infrastructure.persistence.models import UserProfile
from apps.api_server.src.modules.learning_session.infrastructure.persistence.models import SessionQuestion, SessionAnswer, QuestionOption, Question, ChallengeSession
from apps.api_server.src.shared.infrastructure.api.exceptions import APIException
from apps.api_server.src.modules.learning_session.application.dto.challenge_dtos import AnswerRequest

@pytest.fixture
def mock_session():
    return AsyncMock()

@pytest.fixture
def challenge_service(mock_session):
    service = ChallengeService(session=mock_session)
    service.xp_service = AsyncMock()
    return service

@pytest.mark.asyncio
@patch('apps.api_server.src.modules.learning_session.domain.services.challenge_service.generate_poo_questions')
async def test_should_start_challenge_and_create_session(mock_generate, challenge_service, mock_session):
    # Arrange
    user_id = uuid.uuid4()
    mock_generate.return_value = [
        {
            "stem": "Question 1",
            "options": [{"key": "A", "text": "Opt A"}, {"key": "B", "text": "Opt B"}],
            "correct_option_key": "A"
        }
    ]
    
    mock_profile = UserProfile(user_id=user_id, current_level_id=1, xp_total=10)
    challenge_service.xp_service.get_or_create_profile.return_value = mock_profile
    
    # Act
    result = await challenge_service.start_challenge(user_id)
    
    # Assert
    assert mock_generate.called
    assert challenge_service.xp_service.get_or_create_profile.called
    assert mock_session.add.call_count == 5
    assert mock_session.commit.called
    assert "session_id" in result
    assert result["total_questions"] == 1
    assert result["questions"][0]["stem"] == "Question 1"

@pytest.mark.asyncio
@patch('apps.api_server.src.modules.learning_session.domain.services.challenge_service.generate_poo_questions')
async def test_should_fail_start_challenge_when_ai_fails(mock_generate, challenge_service, mock_session):
    # Arrange
    user_id = uuid.uuid4()
    mock_generate.side_effect = Exception("AI Timeout")
    
    # Act & Assert
    with pytest.raises(APIException) as exc:
        await challenge_service.start_challenge(user_id)
    assert exc.value.status_code == 502
    assert "No se pudieron generar las preguntas" in exc.value.message

@pytest.mark.asyncio
async def test_should_fail_answer_if_question_not_found(challenge_service, mock_session):
    # Arrange
    session_id = uuid.uuid4()
    user_id = uuid.uuid4()
    request = AnswerRequest(session_question_id=str(uuid.uuid4()), selected_option_key="A")
    
    async def mock_execute(*args, **kwargs):
        mock_res = MagicMock()
        mock_res.scalars.return_value.first.return_value = None
        return mock_res
        
    mock_session.execute.side_effect = mock_execute
    
    # Act & Assert
    with pytest.raises(APIException) as exc:
        await challenge_service.answer_question(session_id, user_id, request)
    assert exc.value.status_code == 404

@pytest.mark.asyncio
async def test_should_fail_answer_if_already_answered(challenge_service, mock_session):
    # Arrange
    session_id = uuid.uuid4()
    user_id = uuid.uuid4()
    sq_id = uuid.uuid4()
    request = AnswerRequest(session_question_id=str(sq_id), selected_option_key="A")
    
    mock_sq = SessionQuestion(id=sq_id, session_id=session_id)
    mock_ans = SessionAnswer(id=uuid.uuid4())
    
    async def mock_execute(*args, **kwargs):
        mock_res = MagicMock()
        if 'SessionQuestion' in str(args[0]):
            mock_res.scalars.return_value.first.return_value = mock_sq
        elif 'SessionAnswer' in str(args[0]):
            mock_res.scalars.return_value.first.return_value = mock_ans
        return mock_res
        
    mock_session.execute.side_effect = mock_execute
    
    # Act & Assert
    with pytest.raises(APIException) as exc:
        await challenge_service.answer_question(session_id, user_id, request)
    assert exc.value.status_code == 400

@pytest.mark.asyncio
async def test_should_finish_challenge_successfully(challenge_service, mock_session):
    # Arrange
    session_id = uuid.uuid4()
    user_id = uuid.uuid4()
    
    mock_cs = ChallengeSession(id=session_id, user_id=user_id, status="IN_PROGRESS", total_questions=2)
    mock_ans_1 = MagicMock(is_correct=True)
    mock_ans_2 = MagicMock(is_correct=False)
    
    async def mock_execute(*args, **kwargs):
        mock_res = MagicMock()
        query_str = str(args[0])
        if 'challenge_session' in query_str:
            mock_res.scalars.return_value.first.return_value = mock_cs
        elif 'session_answer' in query_str:
            mock_res.scalars.return_value.all.return_value = [mock_ans_1, mock_ans_2]
        return mock_res
        
    mock_session.execute.side_effect = mock_execute
    
    challenge_service.xp_service.apply_session_xp.return_value = {
        "xp_delta": 0, "level_up": False, "floor_applied": False, 
        "xp_after_final": 10, "level_after": 1
    }
    
    # Act
    res = await challenge_service.finish_challenge(session_id, user_id)
    
    # Assert
    assert res["correct_answers"] == 1
    assert res["wrong_answers"] == 1
    assert mock_cs.status == "FINISHED"
    assert challenge_service.xp_service.apply_session_xp.called
    assert mock_session.commit.called

@pytest.mark.asyncio
async def test_should_answer_question_successfully(challenge_service, mock_session):
    # Arrange
    session_id = uuid.uuid4()
    user_id = uuid.uuid4()
    q_id = uuid.uuid4()
    sq_id = uuid.uuid4()
    request = AnswerRequest(session_question_id=str(sq_id), selected_option_key="A", response_time_ms=1000)
    
    mock_sq = SessionQuestion(id=sq_id, session_id=session_id, question_id=q_id)
    mock_opt_1 = QuestionOption(question_id=q_id, option_key="A", is_correct=True)
    mock_opt_2 = QuestionOption(question_id=q_id, option_key="B", is_correct=False)
    mock_q = Question(id=q_id, explanation="Test feedback")
    
    # We mock execute calls sequentially using a side effect
    call_idx = 0
    async def mock_execute(*args, **kwargs):
        nonlocal call_idx
        mock_res = MagicMock()
        
        if call_idx == 0:
            mock_res.scalars.return_value.first.return_value = mock_sq # Validate session question
        elif call_idx == 1:
            mock_res.scalars.return_value.first.return_value = None # Check if already answered
        elif call_idx == 2:
            mock_res.scalars.return_value.all.return_value = [mock_opt_1, mock_opt_2] # Find correct option
        elif call_idx == 3:
            mock_res.scalars.return_value.first.return_value = mock_q # Get explanation
        elif call_idx == 4:
            mock_res.scalar.return_value = 0 # Calculate lives remaining (wrong count)
            
        call_idx += 1
        return mock_res
        
    mock_session.execute.side_effect = mock_execute
    
    # Act
    res = await challenge_service.answer_question(session_id, user_id, request)
    
    # Assert
    assert res.is_correct == True
    assert res.correct_option_key == "A"
    assert res.xp_awarded == 5
    assert res.feedback == "Test feedback"
    assert res.lives_remaining == 3
    assert mock_session.add.called
    assert mock_session.commit.called
