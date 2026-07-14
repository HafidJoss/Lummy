import asyncio
import os
from sqlalchemy.future import select
from dotenv import load_dotenv

# Cargar variables de entorno (como DATABASE_URL) desde .env
load_dotenv()

# Es importante cargar dotenv antes de importar la base de datos para que tome la URL correcta
from src.shared.infrastructure.db.base import async_session_maker
from src.modules.gamification.infrastructure.persistence.models import LevelRule

async def seed():
    async with async_session_maker() as session:
        print("Conectando a la base de datos para verificar reglas de nivel...")
        
        # Verificar si ya existen reglas
        result = await session.execute(select(LevelRule))
        existing_rules = result.scalars().all()
        
        if not existing_rules:
            print("No se encontraron reglas de nivel. Insertando datos semilla...")
            level_rules = [
                LevelRule(level_id=1, xp_min=0, xp_max=99, level_up_cost=100, is_active=True),
                LevelRule(level_id=2, xp_min=100, xp_max=249, level_up_cost=150, is_active=True),
                LevelRule(level_id=3, xp_min=250, xp_max=499, level_up_cost=250, is_active=True),
                LevelRule(level_id=4, xp_min=500, xp_max=999, level_up_cost=500, is_active=True),
                LevelRule(level_id=5, xp_min=1000, xp_max=1999, level_up_cost=1000, is_active=True),
            ]
            
            for rule in level_rules:
                session.add(rule)
                
            await session.commit()
            print("¡Datos semilla (Niveles 1 al 5) insertados correctamente!")
        else:
            print("Las reglas de nivel ya existen. No se realizaron cambios.")

if __name__ == "__main__":
    asyncio.run(seed())
