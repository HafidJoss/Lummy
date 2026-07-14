from fastapi import APIRouter, Depends, UploadFile, File, Request
import os
import shutil
import cloudinary
import cloudinary.uploader
from dotenv import load_dotenv
load_dotenv()
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy import func

from src.shared.infrastructure.api.dependencies import get_db_session, get_current_user
from src.shared.infrastructure.api.exceptions import APIException
from src.modules.identity_access.application.dto.auth_dtos import RegisterRequest, LoginRequest, TokenResponse, AuthUserResponse, UserResponse, UpdateProfileRequest
from src.modules.identity_access.domain.services.auth_service import AuthService
from src.modules.identity_access.infrastructure.persistence.models import User
from src.modules.gamification.domain.services.xp_service import XPService
from src.modules.gamification.infrastructure.persistence.models import UserProfile

auth_router = APIRouter(prefix="/api/v1/auth", tags=["Auth"])

@auth_router.post("/register", response_model=AuthUserResponse)
async def register(request: RegisterRequest, session: AsyncSession = Depends(get_db_session)):
    auth_service = AuthService(session)
    user = await auth_service.register(request)
    return AuthUserResponse(
        id=str(user.id),
        email=user.email,
        full_name=user.full_name,
        is_active=user.is_active
    )

@auth_router.post("/login", response_model=TokenResponse)
async def login(request: LoginRequest, session: AsyncSession = Depends(get_db_session)):
    auth_service = AuthService(session)
    return await auth_service.login(request)

users_router = APIRouter(prefix="/api/v1/users", tags=["Users"])

@users_router.get("/me", response_model=UserResponse)
async def get_me(current_user: dict = Depends(get_current_user), session: AsyncSession = Depends(get_db_session)):
    result = await session.execute(select(User).filter(User.id == current_user["user_id"]))
    user = result.scalars().first()
    if not user:
        raise APIException(code="NOT_FOUND", message="Usuario no encontrado", status_code=404)
        
    xp_service = XPService(session)
    profile = await xp_service.get_or_create_profile(user.id)
    
    current_xp_min = await xp_service.get_floor_xp(profile.current_level_id)
    next_xp_min = await xp_service.get_floor_xp(profile.current_level_id + 1)
    
    # Si next_xp_min es 0 significa que no hay regla para el siguiente nivel (nivel máximo)
    # Podemos asignar next_xp_min = xp_total o current_xp_min para indicar barra llena
    if next_xp_min == 0:
        next_xp_min = current_xp_min
        
    rank_stmt = select(func.count(UserProfile.user_id)).filter(UserProfile.xp_total > profile.xp_total)
    rank_result = await session.execute(rank_stmt)
    better_players = rank_result.scalar() or 0
    rank_position = better_players + 1
        
    return UserResponse(
        id=str(user.id),
        email=user.email,
        full_name=user.full_name,
        display_name=profile.display_name,
        title=profile.title,
        avatar_url=profile.avatar_url,
        xp_total=profile.xp_total,
        current_level_id=profile.current_level_id,
        accuracy_global=float(profile.accuracy_global),
        current_level_xp_min=current_xp_min,
        next_level_xp_min=next_xp_min,
        total_answered=profile.total_answered,
        rank_position=rank_position,
        current_streak=profile.current_streak
    )

@users_router.put("/me", response_model=UserResponse)
async def update_profile(
    request: UpdateProfileRequest,
    current_user: dict = Depends(get_current_user),
    session: AsyncSession = Depends(get_db_session)
):
    result = await session.execute(select(UserProfile).filter(UserProfile.user_id == current_user["user_id"]))
    profile = result.scalars().first()
    if not profile:
        raise APIException(code="NOT_FOUND", message="Perfil no encontrado", status_code=404)
        
    if request.display_name:
        profile.display_name = request.display_name
    if request.title:
        profile.title = request.title
        
    await session.commit()
    return await get_me(current_user, session)

@users_router.post("/me/avatar", response_model=dict)
async def upload_avatar(
    request: Request,
    file: UploadFile = File(...),
    current_user: dict = Depends(get_current_user),
    session: AsyncSession = Depends(get_db_session)
):
    result = await session.execute(select(UserProfile).filter(UserProfile.user_id == current_user["user_id"]))
    profile = result.scalars().first()
    if not profile:
        raise APIException(code="NOT_FOUND", message="Perfil no encontrado", status_code=404)
        
    try:
        # Upload the file directly to Cloudinary
        upload_result = cloudinary.uploader.upload(
            file.file, 
            folder="lummy_avatars",
            public_id=f"avatar_{current_user['user_id']}",
            overwrite=True
        )
        avatar_url = upload_result.get("secure_url")
    except Exception as e:
        raise APIException(code="UPLOAD_ERROR", message=f"Error al subir imagen a Cloudinary: {str(e)}", status_code=500)
    
    profile.avatar_url = avatar_url
    await session.commit()
    
    return {"avatar_url": avatar_url}
