import os
import json
import asyncio
from groq import AsyncGroq
from pydantic import BaseModel, Field


class Option(BaseModel):
    id: str
    text: str


class Question(BaseModel):
    text: str
    options: list[Option]
    correct_option_id: str
    explanation: str


class ChallengeQuestions(BaseModel):
    questions: list[Question] = Field(description="Exactamente 5 preguntas de opción múltiple sobre POO")


# --- Stability Patterns (Release It!) ---
MAX_RETRIES = 3
BASE_DELAY_SECONDS = 1.0
MAX_DELAY_SECONDS = 8.0
REQUEST_TIMEOUT_SECONDS = 30.0

# Modelo Groq (Llama 3.3 70B — rápido y potente)
GROQ_MODEL = "llama-3.3-70b-versatile"


def _get_groq_client() -> AsyncGroq:
    """Crea un cliente asíncrono de Groq con fail-fast si falta la API key."""
    api_key = os.getenv("GROQ_API_KEY")
    if not api_key:
        raise RuntimeError(
            "GROQ_API_KEY no está configurada. "
            "Añádela al archivo .env o a las variables de entorno de Railway."
        )
    return AsyncGroq(api_key=api_key, timeout=REQUEST_TIMEOUT_SECONDS)


async def generate_poo_questions(difficulty: str, user_id: str) -> list[dict]:
    """Genera 5 preguntas dinámicas sobre Programación Orientada a Objetos.

    Implementa reintentos con backoff exponencial + jitter para manejar
    errores transitorios (429 Too Many Requests, 503 Service Unavailable).
    """
    client = _get_groq_client()

    prompt = (
        f"Genera 5 preguntas de opción múltiple sobre Programación Orientada a Objetos en Python. "
        f"La dificultad debe ser {difficulty}. "
        f"Para cada pregunta, provee 4 opciones (A, B, C, D) y la justificación de la respuesta correcta. "
        f"Devuelve ÚNICAMENTE un JSON válido con la siguiente estructura exacta:\n"
        f'{{"questions": [{{"text": "...", "options": [{{"id": "A", "text": "..."}}, '
        f'{{"id": "B", "text": "..."}}, {{"id": "C", "text": "..."}}, {{"id": "D", "text": "..."}}], '
        f'"correct_option_id": "A", "explanation": "..."}}]}}'
    )

    last_exception = None

    for attempt in range(1, MAX_RETRIES + 1):
        try:
            response = await client.chat.completions.create(
                model=GROQ_MODEL,
                messages=[
                    {
                        "role": "system",
                        "content": (
                            "Eres un profesor experto en Programación Orientada a Objetos en Python. "
                            "Responde ÚNICAMENTE con JSON válido, sin texto adicional."
                        ),
                    },
                    {"role": "user", "content": prompt},
                ],
                temperature=0.7,
                response_format={"type": "json_object"},
            )

            raw_text = response.choices[0].message.content
            data = json.loads(raw_text)
            return data["questions"]

        except Exception as e:
            last_exception = e
            error_str = str(e)

            # Solo reintentar en errores transitorios (rate limit o sobrecarga)
            is_transient = any(
                keyword in error_str
                for keyword in ["429", "503", "rate_limit", "overloaded", "timeout", "UNAVAILABLE"]
            )

            if is_transient and attempt < MAX_RETRIES:
                # Backoff exponencial con jitter (Release It! pattern)
                import random
                delay = min(BASE_DELAY_SECONDS * (2 ** (attempt - 1)), MAX_DELAY_SECONDS)
                jitter = random.uniform(0, delay * 0.5)
                await asyncio.sleep(delay + jitter)
                continue

            # Error no transitorio o último intento: propagar
            raise

    # Salvaguarda (nunca debería llegar aquí)
    raise last_exception  # type: ignore
