from logging.config import fileConfig
from sqlalchemy import engine_from_config
from sqlalchemy import pool
from alembic import context
import os
import sys

from pathlib import Path
project_root = str(Path(__file__).resolve().parents[7])
sys.path.insert(0, project_root)

# Importar modelos y base
from apps.api_server.src.shared.infrastructure.db.base import Base

import apps.api_server.src.modules.identity_access.infrastructure.persistence.models
import apps.api_server.src.modules.gamification.infrastructure.persistence.models
import apps.api_server.src.modules.learning_session.infrastructure.persistence.models
import apps.api_server.src.modules.leaderboard.infrastructure.readmodel.models
import apps.api_server.src.modules.analytics_research.infrastructure.persistence.models
import apps.api_server.src.shared.infrastructure.messaging.models

config = context.config

if config.config_file_name is not None:
    fileConfig(config.config_file_name)

target_metadata = Base.metadata

def run_migrations_offline() -> None:
    url = config.get_main_option("sqlalchemy.url")
    context.configure(
        url=url,
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
    )
    with context.begin_transaction():
        context.run_migrations()

def run_migrations_online() -> None:
    connectable = engine_from_config(
        config.get_section(config.config_ini_section, {}),
        prefix="sqlalchemy.",
        poolclass=pool.NullPool,
    )
    with connectable.connect() as connection:
        context.configure(
            connection=connection, target_metadata=target_metadata
        )
        with context.begin_transaction():
            context.run_migrations()

if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()
