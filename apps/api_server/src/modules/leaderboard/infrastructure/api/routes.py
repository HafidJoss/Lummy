from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy import desc, func
import math

from apps.api_server.src.shared.infrastructure.api.dependencies import get_db_session, get_current_user
from apps.api_server.src.modules.leaderboard.application.dto.leaderboard_dtos import (
    LeaderboardResponse, LeaderboardEntry, MyLeaderboardPosition
)
from apps.api_server.src.modules.gamification.infrastructure.persistence.models import UserProfile

leaderboard_router = APIRouter(prefix="/api/v1/leaderboard", tags=["Leaderboard"])

@leaderboard_router.get("", response_model=LeaderboardResponse)
async def get_leaderboard(
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
    session: AsyncSession = Depends(get_db_session)
):
    # Contar total de usuarios para paginación
    count_result = await session.execute(select(func.count(UserProfile.user_id)))
    total_users = count_result.scalar() or 0
    total_pages = max(1, math.ceil(total_users / limit))
    
    offset = (page - 1) * limit
    
    stmt = (
        select(UserProfile)
        .order_by(desc(UserProfile.xp_total))
        .offset(offset)
        .limit(limit)
    )
    result = await session.execute(stmt)
    profiles = result.scalars().all()
    
    items = []
    for rank_offset, profile in enumerate(profiles):
        items.append(LeaderboardEntry(
            rank_position=offset + rank_offset + 1,
            user_id=str(profile.user_id),
            display_name=profile.display_name,
            title=profile.title,
            avatar_url=profile.avatar_url,
            xp_total=profile.xp_total,
            level_id=profile.current_level_id,
            accuracy_global=float(profile.accuracy_global)
        ))
        
    return LeaderboardResponse(page=page, total_pages=total_pages, items=items)

@leaderboard_router.get("/me", response_model=MyLeaderboardPosition)
async def get_my_position(
    current_user: dict = Depends(get_current_user), 
    session: AsyncSession = Depends(get_db_session)
):
    import uuid
    uid = uuid.UUID(current_user["user_id"])
    
    stmt = select(UserProfile).filter(UserProfile.user_id == uid)
    result = await session.execute(stmt)
    profile = result.scalars().first()
    
    if not profile:
        return MyLeaderboardPosition(rank_position=0, xp_total=0, level_id=1)
        
    rank_stmt = select(func.count(UserProfile.user_id)).filter(UserProfile.xp_total > profile.xp_total)
    rank_result = await session.execute(rank_stmt)
    better_players = rank_result.scalar() or 0
    
    return MyLeaderboardPosition(
        rank_position=better_players + 1,
        xp_total=profile.xp_total,
        level_id=profile.current_level_id
    )
