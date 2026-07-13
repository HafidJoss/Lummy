from sqlalchemy import Column, Integer, String, Boolean, DateTime, Numeric, Text, SmallInteger
from sqlalchemy.dialects.postgresql import UUID
import uuid
from sqlalchemy import CheckConstraint
from sqlalchemy.sql import func
from src.shared.infrastructure.db.base import Base

class LevelRule(Base):
    __tablename__ = "level_rules"

    level_id = Column(SmallInteger, primary_key=True)
    xp_min = Column(Integer, nullable=False)
    xp_max = Column(Integer, nullable=False)
    level_up_cost = Column(Integer, nullable=False)
    is_active = Column(Boolean, nullable=False, default=True)
    created_at = Column(DateTime(timezone=True), nullable=False, server_default=func.now())
    updated_at = Column(DateTime(timezone=True), nullable=False, server_default=func.now(), onupdate=func.now())

    __table_args__ = (
        CheckConstraint('xp_min >= 0', name='check_xp_min_positive'),
        CheckConstraint('xp_max >= xp_min', name='check_xp_max_valid'),
        CheckConstraint('level_up_cost > 0', name='check_level_cost_positive'),
    )

class UserProfile(Base):
    __tablename__ = "user_profiles"

    user_id = Column(UUID(as_uuid=True), primary_key=True)
    display_name = Column(Text, unique=True, nullable=False)
    title = Column(Text, nullable=False, default="Explorador Novato", server_default="Explorador Novato")
    avatar_url = Column(Text, nullable=True)
    xp_total = Column(Integer, nullable=False, default=0)
    current_level_id = Column(SmallInteger, nullable=False)
    accuracy_global = Column(Numeric(5, 2), nullable=False, default=0)
    total_answered = Column(Integer, nullable=False, default=0)
    total_correct = Column(Integer, nullable=False, default=0)
    current_streak = Column(Integer, nullable=False, default=0)
    created_at = Column(DateTime(timezone=True), nullable=False, server_default=func.now())
    updated_at = Column(DateTime(timezone=True), nullable=False, server_default=func.now(), onupdate=func.now())

    __table_args__ = (
        CheckConstraint('xp_total >= 0', name='check_xp_total_positive'),
        CheckConstraint('accuracy_global >= 0 AND accuracy_global <= 100', name='check_accuracy_valid'),
        CheckConstraint('total_answered >= 0', name='check_total_answered_positive'),
        CheckConstraint('total_correct >= 0 AND total_correct <= total_answered', name='check_total_correct_valid'),
        CheckConstraint('current_streak >= 0', name='check_current_streak_positive'),
    )

class XpLedger(Base):
    __tablename__ = "xp_ledger"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), nullable=False)
    session_id = Column(UUID(as_uuid=True), nullable=True)
    entry_type = Column(Text, nullable=False)
    xp_amount = Column(Integer, nullable=False)
    balance_before = Column(Integer, nullable=False)
    balance_after = Column(Integer, nullable=False)
    reason = Column(Text, nullable=False)
    created_at = Column(DateTime(timezone=True), nullable=False, server_default=func.now())

    __table_args__ = (
        CheckConstraint("entry_type IN ('GAIN','LOSS','ADJUSTMENT','FLOOR_PROTECTION')", name='check_entry_type'),
        CheckConstraint('balance_before >= 0', name='check_balance_before_positive'),
        CheckConstraint('balance_after >= 0', name='check_balance_after_positive'),
    )
