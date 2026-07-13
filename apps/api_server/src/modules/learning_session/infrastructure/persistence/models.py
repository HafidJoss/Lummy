from sqlalchemy import Column, Integer, Text, Boolean, DateTime, Numeric, SmallInteger
from sqlalchemy.dialects.postgresql import UUID, JSONB
import uuid
from sqlalchemy import CheckConstraint
from sqlalchemy.sql import func
from src.shared.infrastructure.db.base import Base

class QuestionTopic(Base):
    __tablename__ = "question_topics"

    id = Column(SmallInteger, primary_key=True)
    topic_key = Column(Text, unique=True, nullable=False)
    topic_name = Column(Text, nullable=False)
    description = Column(Text, nullable=True)
    is_active = Column(Boolean, nullable=False, default=True)
    created_at = Column(DateTime(timezone=True), nullable=False, server_default=func.now())

class Question(Base):
    __tablename__ = "questions"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    topic_id = Column(SmallInteger, nullable=False)
    difficulty = Column(SmallInteger, nullable=False)
    stem = Column(Text, nullable=False)
    explanation = Column(Text, nullable=False)
    source_type = Column(Text, nullable=False)
    source_ref = Column(Text, nullable=True)
    language_code = Column(Text, nullable=False, default='es-PE')
    content_hash = Column(Text, unique=True, nullable=False)
    is_active = Column(Boolean, nullable=False, default=True)
    created_at = Column(DateTime(timezone=True), nullable=False, server_default=func.now())

    __table_args__ = (
        CheckConstraint('difficulty BETWEEN 1 AND 5', name='check_difficulty_valid'),
        CheckConstraint("source_type IN ('AI','CURATED','FALLBACK')", name='check_source_type_valid'),
    )

class QuestionOption(Base):
    __tablename__ = "question_options"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    question_id = Column(UUID(as_uuid=True), nullable=False)
    option_key = Column(Text, nullable=False)
    option_text = Column(Text, nullable=False)
    is_correct = Column(Boolean, nullable=False)
    position = Column(SmallInteger, nullable=False)
    created_at = Column(DateTime(timezone=True), nullable=False, server_default=func.now())

    __table_args__ = (
        CheckConstraint('position BETWEEN 1 AND 6', name='check_position_valid'),
    )

class ChallengeSession(Base):
    __tablename__ = "challenge_sessions"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), nullable=False)
    level_id_at_start = Column(SmallInteger, nullable=False)
    status = Column(Text, nullable=False)
    total_questions = Column(Integer, nullable=False, default=5)
    answered_questions = Column(Integer, nullable=False, default=0)
    correct_answers = Column(Integer, nullable=False, default=0)
    wrong_answers = Column(Integer, nullable=False, default=0)
    xp_delta = Column(Integer, nullable=False, default=0)
    accuracy_session = Column(Numeric(5,2), nullable=True)
    started_xp = Column(Integer, nullable=False)
    ended_xp = Column(Integer, nullable=True)
    started_at = Column(DateTime(timezone=True), nullable=False, server_default=func.now())
    finished_at = Column(DateTime(timezone=True), nullable=True)
    duration_seconds = Column(Integer, nullable=True)
    generation_context = Column(JSONB, nullable=True)
    generation_meta = Column(JSONB, nullable=True)

    __table_args__ = (
        CheckConstraint("status IN ('IN_PROGRESS','FINISHED','ABANDONED')", name='check_status_valid'),
    )

class SessionQuestion(Base):
    __tablename__ = "session_questions"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    session_id = Column(UUID(as_uuid=True), nullable=False)
    question_id = Column(UUID(as_uuid=True), nullable=False)
    order_in_session = Column(SmallInteger, nullable=False)
    difficulty_at_delivery = Column(SmallInteger, nullable=False)
    topic_id = Column(SmallInteger, nullable=False)
    delivered_at = Column(DateTime(timezone=True), nullable=False, server_default=func.now())

class SessionAnswer(Base):
    __tablename__ = "session_answers"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    session_question_id = Column(UUID(as_uuid=True), unique=True, nullable=False)
    session_id = Column(UUID(as_uuid=True), nullable=False)
    user_id = Column(UUID(as_uuid=True), nullable=False)
    selected_option_key = Column(Text, nullable=False)
    is_correct = Column(Boolean, nullable=False)
    response_time_ms = Column(Integer, nullable=False)
    answered_at = Column(DateTime(timezone=True), nullable=False, server_default=func.now())
    feedback_payload = Column(JSONB, nullable=True)

class SessionResult(Base):
    __tablename__ = "session_results"

    session_id = Column(UUID(as_uuid=True), primary_key=True)
    xp_before = Column(Integer, nullable=False)
    xp_gained = Column(Integer, nullable=False)
    xp_lost = Column(Integer, nullable=False)
    xp_after_raw = Column(Integer, nullable=False)
    xp_after_floor = Column(Integer, nullable=False)
    xp_after_final = Column(Integer, nullable=False)
    level_before = Column(SmallInteger, nullable=False)
    level_after = Column(SmallInteger, nullable=False)
    level_up = Column(Boolean, nullable=False)
    floor_applied = Column(Boolean, nullable=False)
    computed_at = Column(DateTime(timezone=True), nullable=False, server_default=func.now())
