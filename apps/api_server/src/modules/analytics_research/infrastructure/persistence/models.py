from sqlalchemy import Column, Integer, Text, DateTime, Numeric
from sqlalchemy.dialects.postgresql import UUID, JSONB
import uuid
from sqlalchemy import CheckConstraint
from sqlalchemy.sql import func
from src.shared.infrastructure.db.base import Base

class LearningEventLog(Base):
    __tablename__ = "learning_event_log"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), nullable=False)
    session_id = Column(UUID(as_uuid=True), nullable=True)
    event_type = Column(Text, nullable=False)
    event_payload = Column(JSONB, nullable=False, default={})
    created_at = Column(DateTime(timezone=True), nullable=False, server_default=func.now())

class PrepostTestAttempt(Base):
    __tablename__ = "prepost_test_attempts"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), nullable=False)
    test_type = Column(Text, nullable=False)
    score = Column(Integer, nullable=False)
    total_questions = Column(Integer, nullable=False)
    score_percent = Column(Numeric(5,2), nullable=False)
    started_at = Column(DateTime(timezone=True), nullable=False)
    finished_at = Column(DateTime(timezone=True), nullable=False)
    duration_seconds = Column(Integer, nullable=False)
    metadata_json = Column("metadata", JSONB, nullable=False, default={})

    __table_args__ = (
        CheckConstraint("test_type IN ('PRE_TEST','POST_TEST')", name='check_test_type_valid'),
        CheckConstraint("score >= 0", name='check_prepost_score_positive'),
        CheckConstraint("total_questions > 0", name='check_prepost_total_questions_valid'),
        CheckConstraint("score_percent >= 0 AND score_percent <= 100", name='check_prepost_score_percent_valid'),
        CheckConstraint("duration_seconds >= 0", name='check_prepost_duration_valid'),
    )
