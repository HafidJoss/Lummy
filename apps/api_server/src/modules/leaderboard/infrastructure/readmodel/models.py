from sqlalchemy import Column, Integer, Text, DateTime, Numeric, SmallInteger
from sqlalchemy.dialects.postgresql import UUID
import uuid
from sqlalchemy import CheckConstraint
from sqlalchemy.sql import func
from apps.api_server.src.shared.infrastructure.db.base import Base

class LeaderboardRun(Base):
    __tablename__ = "leaderboard_runs"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    run_type = Column(Text, nullable=False)
    started_at = Column(DateTime(timezone=True), nullable=False, server_default=func.now())
    finished_at = Column(DateTime(timezone=True), nullable=True)
    status = Column(Text, nullable=False)
    total_rows = Column(Integer, nullable=True)
    triggered_by = Column(Text, nullable=False)

    __table_args__ = (
        CheckConstraint("run_type IN ('FULL','INCREMENTAL')", name='check_run_type_valid'),
        CheckConstraint("status IN ('RUNNING','SUCCESS','FAILED')", name='check_leaderboard_status_valid'),
        CheckConstraint("triggered_by IN ('SCHEDULER','EVENT_WORKER','MANUAL')", name='check_triggered_by_valid'),
    )

class LeaderboardSnapshot(Base):
    __tablename__ = "leaderboard_snapshots"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    run_id = Column(UUID(as_uuid=True), nullable=False)
    user_id = Column(UUID(as_uuid=True), nullable=False)
    rank_position = Column(Integer, nullable=False)
    xp_total = Column(Integer, nullable=False)
    level_id = Column(SmallInteger, nullable=False)
    accuracy_global = Column(Numeric(5,2), nullable=False)
    snapshot_at = Column(DateTime(timezone=True), nullable=False, server_default=func.now())
