from typing import AsyncGenerator
from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker, AsyncSession
from sqlalchemy.orm import declarative_base
import os

# Obtener URL desde entorno (usando .env si se cargó previamente con python-dotenv)
# o un valor por defecto para fallback.
DATABASE_URL = os.getenv("DATABASE_URL", "postgresql+asyncpg://postgres:postgres@localhost:5435/gamified_poo")

# Crear el motor asíncrono
engine = create_async_engine(DATABASE_URL, echo=False)

# Configurar el session maker asíncrono
async_session_maker = async_sessionmaker(
    bind=engine,
    class_=AsyncSession,
    expire_on_commit=False,
    autoflush=False
)

# Base declarativa para los modelos
Base = declarative_base()

# Dependencia para inyectar la sesión en las rutas de FastAPI
async def get_db_session() -> AsyncGenerator[AsyncSession, None]:
    async with async_session_maker() as session:
        yield session
