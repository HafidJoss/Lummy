from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
import uuid
from typing import Optional
from decimal import Decimal

from apps.api_server.src.modules.gamification.infrastructure.persistence.models import UserProfile, XpLedger, LevelRule

class XPService:
    def __init__(self, session: AsyncSession):
        self.session = session

    async def get_level_for_xp(self, xp_total: int) -> int:
        """Determina el nivel basado en level_rules de la BD."""
        result = await self.session.execute(
            select(LevelRule)
            .filter(LevelRule.is_active == True)
            .filter(LevelRule.xp_min <= xp_total)
            .order_by(LevelRule.level_id.desc())
        )
        rule = result.scalars().first()
        return rule.level_id if rule else 1

    async def get_floor_xp(self, level_id: int) -> int:
        """Obtiene el XP mínimo (piso) del nivel actual desde level_rules."""
        result = await self.session.execute(
            select(LevelRule).filter(LevelRule.level_id == level_id)
        )
        rule = result.scalars().first()
        return rule.xp_min if rule else 0

    async def get_or_create_profile(self, user_id: uuid.UUID) -> UserProfile:
        result = await self.session.execute(select(UserProfile).filter(UserProfile.user_id == user_id))
        profile = result.scalars().first()
        if not profile:
            profile = UserProfile(
                user_id=user_id,
                display_name=str(user_id)[:8],
                xp_total=0,
                current_level_id=1,
                accuracy_global=Decimal("0.00"),
                total_answered=0,
                total_correct=0
            )
            self.session.add(profile)
            await self.session.flush()
        return profile

    async def apply_session_xp(
        self, 
        user_id: uuid.UUID, 
        xp_gained: int, 
        xp_lost: int,
        correct_answers: int,
        total_questions: int,
        challenge_session_id: uuid.UUID
    ) -> dict:
        """
        Aplica el resultado de una sesión al perfil del usuario.
        Implementa el piso antifrustración (RF-015).
        Retorna un diccionario con el desglose completo para el contrato.
        """
        profile = await self.get_or_create_profile(user_id)
        
        xp_before = profile.xp_total
        level_before = profile.current_level_id
        
        xp_delta = xp_gained - xp_lost
        xp_after_raw = xp_before + xp_delta
        
        # Piso antifrustración: no bajar del XP mínimo del nivel consolidado
        floor_xp = await self.get_floor_xp(level_before)
        floor_applied = False
        
        if xp_after_raw < floor_xp:
            xp_after_floor = floor_xp
            floor_applied = True
        else:
            xp_after_floor = max(0, xp_after_raw)
        
        xp_after_final = xp_after_floor
        
        # Determinar nuevo nivel
        level_after = await self.get_level_for_xp(xp_after_final)
        level_up = level_after > level_before
        
        # Actualizar perfil
        profile.xp_total = xp_after_final
        profile.current_level_id = level_after
        profile.total_answered += total_questions
        profile.total_correct += correct_answers
        if profile.total_answered > 0:
            profile.accuracy_global = Decimal(str(round((profile.total_correct / profile.total_answered) * 100, 2)))
        
        # Registrar en XP Ledger
        if xp_gained > 0:
            self.session.add(XpLedger(
                id=uuid.uuid4(),
                user_id=user_id,
                session_id=challenge_session_id,
                entry_type="GAIN",
                xp_amount=xp_gained,
                balance_before=xp_before,
                balance_after=xp_after_final,
                reason="challenge_correct_answers"
            ))
        
        if xp_lost > 0:
            self.session.add(XpLedger(
                id=uuid.uuid4(),
                user_id=user_id,
                session_id=challenge_session_id,
                entry_type="LOSS",
                xp_amount=-xp_lost,
                balance_before=xp_before,
                balance_after=xp_after_final,
                reason="challenge_wrong_answers"
            ))
        
        if floor_applied:
            self.session.add(XpLedger(
                id=uuid.uuid4(),
                user_id=user_id,
                session_id=challenge_session_id,
                entry_type="FLOOR_PROTECTION",
                xp_amount=xp_after_floor - xp_after_raw,
                balance_before=max(0, xp_after_raw),
                balance_after=xp_after_floor,
                reason=f"floor_protection_level_{level_before}"
            ))
        
        return {
            "xp_before": xp_before,
            "xp_gained": xp_gained,
            "xp_lost": xp_lost,
            "xp_delta": xp_delta,
            "xp_after_raw": xp_after_raw,
            "xp_after_floor": xp_after_floor,
            "xp_after_final": xp_after_final,
            "level_before": level_before,
            "level_after": level_after,
            "level_up": level_up,
            "floor_applied": floor_applied,
        }
