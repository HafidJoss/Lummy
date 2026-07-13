from fastapi import APIRouter, Depends
from fastapi.responses import JSONResponse
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
import uuid
from datetime import datetime, timezone

from src.shared.infrastructure.api.dependencies import get_db_session, get_current_user
from src.shared.infrastructure.api.exceptions import APIException
from src.modules.analytics_research.application.dto.analytics_dtos import TestAttemptRequest, TestAttemptResponse
from src.modules.analytics_research.infrastructure.persistence.models import PrepostTestAttempt

analytics_router = APIRouter(prefix="/api/v1/analytics", tags=["Analytics & Research"])

@analytics_router.post("/test-attempt", response_model=TestAttemptResponse, status_code=201)
async def submit_test_attempt(
    request: TestAttemptRequest,
    current_user: dict = Depends(get_current_user),
    session: AsyncSession = Depends(get_db_session)
):
    if request.test_type not in ("PRE_TEST", "POST_TEST"):
        raise APIException(code="INVALID_TEST_TYPE", message="test_type debe ser PRE_TEST o POST_TEST", status_code=400)
    
    now = datetime.now(timezone.utc)
    score_percent = round((request.score / request.total_questions) * 100, 2) if request.total_questions > 0 else 0.0
    
    attempt = PrepostTestAttempt(
        id=uuid.uuid4(),
        user_id=uuid.UUID(current_user["user_id"]),
        test_type=request.test_type,
        score=request.score,
        total_questions=request.total_questions,
        score_percent=score_percent,
        started_at=now,
        finished_at=now,
        duration_seconds=request.duration_seconds,
        metadata_json=request.metadata or {}
    )
    session.add(attempt)
    await session.commit()
    
    return TestAttemptResponse(id=str(attempt.id))

@analytics_router.get("/export")
async def export_data(
    current_user: dict = Depends(get_current_user),
    session: AsyncSession = Depends(get_db_session)
):
    # Verificar que sea admin/investigador (para MVP, cualquier usuario autenticado)
    result = await session.execute(select(PrepostTestAttempt))
    attempts = result.scalars().all()
    
    export_data = []
    for attempt in attempts:
        export_data.append({
            "user_id": str(attempt.user_id),
            "test_type": attempt.test_type,
            "score": attempt.score,
            "total_questions": attempt.total_questions,
            "score_percent": float(attempt.score_percent),
            "duration_seconds": attempt.duration_seconds,
            "finished_at": attempt.finished_at.isoformat() if attempt.finished_at else None,
        })
    
    return JSONResponse(content={"data": export_data, "total": len(export_data)})
