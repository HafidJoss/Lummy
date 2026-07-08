from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
import uuid

from apps.api_server.src.shared.infrastructure.api.dependencies import get_db_session, get_current_user
from apps.api_server.src.modules.learning_session.application.dto.challenge_dtos import (
    StartChallengeResponse, AnswerRequest, AnswerResponse, FinishChallengeResponse
)
from apps.api_server.src.modules.learning_session.domain.services.challenge_service import ChallengeService

challenge_router = APIRouter(prefix="/api/v1/challenge", tags=["Challenge"])

@challenge_router.post("/start", response_model=StartChallengeResponse, status_code=201)
async def start_challenge(current_user: dict = Depends(get_current_user), session: AsyncSession = Depends(get_db_session)):
    service = ChallengeService(session)
    result = await service.start_challenge(uuid.UUID(current_user["user_id"]))
    return StartChallengeResponse(**result)

@challenge_router.post("/{session_id}/answer", response_model=AnswerResponse)
async def answer_question(session_id: str, request: AnswerRequest, current_user: dict = Depends(get_current_user), session: AsyncSession = Depends(get_db_session)):
    service = ChallengeService(session)
    return await service.answer_question(uuid.UUID(session_id), uuid.UUID(current_user["user_id"]), request)

@challenge_router.post("/{session_id}/finish", response_model=FinishChallengeResponse)
async def finish_challenge(session_id: str, current_user: dict = Depends(get_current_user), session: AsyncSession = Depends(get_db_session)):
    service = ChallengeService(session)
    result = await service.finish_challenge(uuid.UUID(session_id), uuid.UUID(current_user["user_id"]))
    return FinishChallengeResponse(**result)
