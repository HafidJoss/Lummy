from pydantic import BaseModel, EmailStr, Field
from typing import Optional

class RegisterRequest(BaseModel):
    email: EmailStr
    password: str = Field(..., max_length=50)
    full_name: str

class LoginRequest(BaseModel):
    email: EmailStr
    password: str

class UpdateProfileRequest(BaseModel):
    display_name: Optional[str] = Field(None, min_length=3, max_length=50)
    title: Optional[str] = Field(None, min_length=2, max_length=50)

class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_in: int = 86400  # seconds (24h default)

class RefreshRequest(BaseModel):
    refresh_token: str

class RefreshResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    expires_in: int = 86400

class LogoutResponse(BaseModel):
    message: str = "Sesión cerrada correctamente"

class AuthUserResponse(BaseModel):
    id: str
    email: EmailStr
    full_name: str
    is_active: bool

class UserResponse(BaseModel):
    id: str
    email: EmailStr
    full_name: str
    display_name: str
    title: str
    avatar_url: Optional[str] = None
    xp_total: int
    current_level_id: int
    accuracy_global: float
    current_level_xp_min: int
    next_level_xp_min: int
    total_answered: int
    rank_position: int
    current_streak: int
