from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
import uuid
from datetime import datetime, timezone

from apps.api_server.src.modules.identity_access.infrastructure.persistence.models import User, UserAuthSession
from apps.api_server.src.modules.gamification.infrastructure.persistence.models import UserProfile
from apps.api_server.src.shared.infrastructure.security.jwt_service import (
    get_password_hash, verify_password, create_access_token, create_refresh_token, 
    decode_token, ACCESS_TOKEN_EXPIRE_MINUTES
)
from apps.api_server.src.shared.infrastructure.api.exceptions import APIException
from apps.api_server.src.modules.identity_access.application.dto.auth_dtos import (
    RegisterRequest, LoginRequest, TokenResponse, RefreshRequest, RefreshResponse
)

class AuthService:
    def __init__(self, session: AsyncSession):
        self.session = session

    async def register(self, request: RegisterRequest) -> User:
        result = await self.session.execute(select(User).filter(User.email == request.email))
        if result.scalars().first():
            raise APIException(code="EMAIL_IN_USE", message="El correo electrónico ya está registrado", status_code=400)
        
        hashed_pw = get_password_hash(request.password)
        user_id = uuid.uuid4()
        new_user = User(
            id=user_id,
            email=request.email,
            password_hash=hashed_pw,
            full_name=request.full_name,
            is_active=True
        )
        self.session.add(new_user)
        
        # Crear UserProfile gamificado al registrar (display_name derivado del nombre)
        display_name = request.full_name.lower().replace(" ", "_")[:20] + "_" + str(user_id)[:4]
        profile = UserProfile(
            user_id=user_id,
            display_name=display_name,
            xp_total=0,
            current_level_id=1,
            accuracy_global=0.0,
            total_answered=0,
            total_correct=0
        )
        self.session.add(profile)
        
        await self.session.commit()
        await self.session.refresh(new_user)
        return new_user

    async def login(self, request: LoginRequest) -> TokenResponse:
        result = await self.session.execute(select(User).filter(User.email == request.email))
        user = result.scalars().first()
        
        if not user or not verify_password(request.password, user.password_hash):
            raise APIException(code="INVALID_CREDENTIALS", message="Credenciales incorrectas", status_code=401)
        
        if not user.is_active:
            raise APIException(code="USER_INACTIVE", message="Usuario inactivo", status_code=403)
            
        user.last_login_at = datetime.now(timezone.utc)
        await self.session.commit()
        
        access_token = create_access_token(data={"sub": str(user.id), "email": user.email, "role": "student"})
        refresh_token = create_refresh_token(data={"sub": str(user.id), "email": user.email})
        
        return TokenResponse(
            access_token=access_token,
            refresh_token=refresh_token,
            expires_in=ACCESS_TOKEN_EXPIRE_MINUTES * 60
        )

    async def refresh_token(self, request: RefreshRequest) -> RefreshResponse:
        payload = decode_token(request.refresh_token)
        if not payload or payload.get("type") != "refresh":
            raise APIException(code="INVALID_TOKEN", message="Refresh token inválido o expirado", status_code=401)
        
        user_id = payload.get("sub")
        email = payload.get("email")
        
        new_access_token = create_access_token(data={"sub": user_id, "email": email, "role": "student"})
        
        return RefreshResponse(
            access_token=new_access_token,
            expires_in=ACCESS_TOKEN_EXPIRE_MINUTES * 60
        )

    async def logout(self, user_id: str) -> None:
        """Revoca refresh tokens del usuario. Para MVP, simplemente invalida la sesión."""
        # En una implementación completa se revocaría el refresh_token en user_auth_sessions
        # Para MVP, el frontend simplemente borra los tokens locales
        pass
