from sqlalchemy import Column, Integer, Text, DateTime, Boolean
from sqlalchemy.dialects.postgresql import UUID, JSONB
import uuid
from sqlalchemy import CheckConstraint
from sqlalchemy.sql import func
from src.shared.infrastructure.db.base import Base

class OutboxEvent(Base):
    __tablename__ = "outbox_events"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    event_type = Column(Text, nullable=False)
    aggregate_id = Column(UUID(as_uuid=True), nullable=False)
    aggregate_type = Column(Text, nullable=False)
    payload = Column(JSONB, nullable=False)
    occurred_at = Column(DateTime(timezone=True), nullable=False)
    created_at = Column(DateTime(timezone=True), nullable=False, server_default=func.now())
    published_at = Column(DateTime(timezone=True), nullable=True)
    status = Column(Text, nullable=False, default='PENDING')
    retry_count = Column(Integer, nullable=False, default=0)
    last_error = Column(Text, nullable=True)

    __table_args__ = (
        CheckConstraint("status IN ('PENDING','PUBLISHED','FAILED')", name='check_outbox_status_valid'),
    )

class OutboxEventDelivery(Base):
    __tablename__ = "outbox_event_deliveries"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    outbox_event_id = Column(UUID(as_uuid=True), nullable=False)
    broker = Column(Text, nullable=False)
    topic_or_queue = Column(Text, nullable=False)
    attempted_at = Column(DateTime(timezone=True), nullable=False, server_default=func.now())
    success = Column(Boolean, nullable=False)
    error_message = Column(Text, nullable=True)

class ConsumerProcessedEvent(Base):
    __tablename__ = "consumer_processed_events"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    consumer_name = Column(Text, nullable=False)
    outbox_event_id = Column(UUID(as_uuid=True), nullable=False)
    processed_at = Column(DateTime(timezone=True), nullable=False, server_default=func.now())
    status = Column(Text, nullable=False)

    __table_args__ = (
        CheckConstraint("status IN ('PROCESSED','SKIPPED','FAILED')", name='check_consumer_status_valid'),
    )
