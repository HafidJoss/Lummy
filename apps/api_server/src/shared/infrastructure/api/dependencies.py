from fastapi import Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.ext.asyncio import AsyncSession
from collections.abc import AsyncGenerator

from apps.api_server.src.shared.infrastructure.db.base import async_session_maker
from apps.api_server.src.shared.infrastructure.security.jwt_service import decode_token
from apps.api_server.src.shared.infrastructure.api.exceptions import APIException

security = HTTPBearer()

async def get_db_session() -> AsyncGenerator[AsyncSession, None]:
    async with async_session_maker() as session:
        yield session

async def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(security)) -> dict:
    token = credentials.credentials
    payload = decode_token(token)
    if not payload or payload.get("type") != "access":
        raise APIException(
            code="UNAUTHORIZED",
            message="Token inválido o expirado",
            status_code=401
        )
    return {
        "user_id": payload.get("sub"),
        "role": payload.get("role", "student")
    }
