from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
import os
from src.shared.infrastructure.api.exceptions import APIException, api_exception_handler, global_exception_handler

app = FastAPI(
    title="Gamified POO AI System",
    description="MVP Backend para el sistema de aprendizaje gamificado con IA",
    version="1.0.0"
)

# CORS config
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], # Para desarrollo
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Servir archivos estáticos
os.makedirs("static", exist_ok=True)
app.mount("/static", StaticFiles(directory="static"), name="static")

# Manejador global de errores
app.add_exception_handler(APIException, api_exception_handler)
app.add_exception_handler(Exception, global_exception_handler)

from src.modules.identity_access.infrastructure.api.routes import auth_router, users_router
from src.modules.learning_session.infrastructure.api.routes import challenge_router
from src.modules.leaderboard.infrastructure.api.routes import leaderboard_router
from src.modules.analytics_research.infrastructure.api.routes import analytics_router

app.include_router(auth_router)
app.include_router(users_router)
app.include_router(challenge_router)
app.include_router(leaderboard_router)
app.include_router(analytics_router)

@app.get("/health")
async def health_check():
    return {"status": "ok", "message": "Gamified POO System running!"}
