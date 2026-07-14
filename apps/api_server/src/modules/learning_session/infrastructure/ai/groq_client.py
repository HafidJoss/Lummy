"""Cliente asíncrono de Groq para generación de preguntas de POO.

Aplica patrones de estabilidad (Release It!):
- Timeout explícito por llamada.
- Reintentos con backoff exponencial + jitter para errores transitorios.
- Fail-fast si la API key no está configurada.
"""

import os
import json
import random
import asyncio
from groq import AsyncGroq


# --- Stability Patterns (Release It!) ---
MAX_RETRIES = 3
BASE_DELAY_SECONDS = 1.0
MAX_DELAY_SECONDS = 8.0
REQUEST_TIMEOUT_SECONDS = 30.0

# Rotación temática anti-repetición (RF-008)
RECENT_TOPICS_WINDOW = 15

# Modelo Groq (Llama 3.3 70B — rápido y potente)
GROQ_MODEL = "llama-3.3-70b-versatile"

# Catálogo de subtemas de POO para que la IA rote creativamente
POO_SUBTOPICS = [
    "Clases y objetos", "Herencia simple", "Herencia múltiple",
    "Polimorfismo", "Encapsulamiento", "Abstracción",
    "Métodos mágicos (__init__, __str__, __repr__)",
    "Decoradores (@property, @staticmethod, @classmethod)",
    "Composición vs herencia", "Interfaces y protocolos",
    "Principio de responsabilidad única (SRP)",
    "Principio abierto/cerrado (OCP)", "MRO (Method Resolution Order)",
    "Métodos de clase vs métodos estáticos", "Atributos de clase vs instancia",
    "Manejo de excepciones con clases", "Dataclasses",
    "Clases abstractas (ABC)", "Mixins", "Sobrecarga de operadores",
]


def _get_groq_client() -> AsyncGroq:
    """Crea un cliente asíncrono de Groq con fail-fast si falta la API key."""
    api_key = os.getenv("GROQ_API_KEY")
    if not api_key:
        raise RuntimeError(
            "GROQ_API_KEY no está configurada. "
            "Añádela al archivo .env o a las variables de entorno de Railway."
        )
    return AsyncGroq(api_key=api_key, timeout=REQUEST_TIMEOUT_SECONDS)


def _build_exclusion_clause(recent_topics: list[str]) -> str:
    """Construye la cláusula de exclusión de temas para el prompt."""
    if not recent_topics:
        return ""
    topics_csv = ", ".join(recent_topics)
    return (
        f"\n\nIMPORTANTE: El usuario ya practicó estos temas recientemente. "
        f"EXCLUYE estrictamente preguntas sobre: [{topics_csv}]. "
        f"Genera preguntas sobre temas DIFERENTES de POO."
    )


def _pick_suggested_topics(recent_topics: list[str], count: int = 3) -> str:
    """Sugiere subtemas aleatorios que NO estén en el historial reciente."""
    available = [t for t in POO_SUBTOPICS if t.lower() not in {r.lower() for r in recent_topics}]
    if not available:
        available = POO_SUBTOPICS  # Fallback si el usuario ya cubrió todo
    chosen = random.sample(available, min(count, len(available)))
    return ", ".join(chosen)


def _build_prompt(difficulty: str, recent_topics: list[str]) -> str:
    """Construye el prompt completo para la generación de preguntas."""
    suggested = _pick_suggested_topics(recent_topics)
    exclusion = _build_exclusion_clause(recent_topics)

    return (
        f"Genera 5 preguntas de opción múltiple sobre Programación Orientada a Objetos en Python. "
        f"La dificultad debe ser {difficulty}. "
        f"Enfócate en los siguientes temas: {suggested}. "
        f"Para cada pregunta, provee 4 opciones (A, B, C, D) y la justificación de la respuesta correcta. "
        f"Incluye el campo 'topic' con el nombre del subtema de POO que trata cada pregunta. "
        f"Devuelve ÚNICAMENTE un JSON válido con la siguiente estructura exacta:\n"
        f'{{"questions": [{{"text": "...", "topic": "Polimorfismo", "options": [{{"id": "A", "text": "..."}}, '
        f'{{"id": "B", "text": "..."}}, {{"id": "C", "text": "..."}}, {{"id": "D", "text": "..."}}], '
        f'"correct_option_id": "A", "explanation": "..."}}]}}'
        f"{exclusion}"
    )


async def generate_poo_questions(
    difficulty: str,
    user_id: str,
    recent_topics: list[str] | None = None,
) -> list[dict]:
    """Genera 5 preguntas dinámicas sobre Programación Orientada a Objetos.

    Args:
        difficulty: Nivel de dificultad (ej. "intermedio").
        user_id: ID del usuario (para trazabilidad).
        recent_topics: Temas que el usuario ya practicó (RF-008 anti-repetición).

    Returns:
        Lista de diccionarios con las preguntas generadas, cada uno con campo 'topic'.

    Raises:
        RuntimeError: Si GROQ_API_KEY no está configurada.
        Exception: Si la IA falla después de agotar los reintentos.
    """
    client = _get_groq_client()
    prompt = _build_prompt(difficulty, recent_topics or [])

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
                            "Siempre varías los temas y ejemplos para mantener al estudiante interesado. "
                            "Responde ÚNICAMENTE con JSON válido, sin texto adicional."
                        ),
                    },
                    {"role": "user", "content": prompt},
                ],
                temperature=0.9,
                response_format={"type": "json_object"},
            )

            raw_text = response.choices[0].message.content
            data = json.loads(raw_text)
            return data["questions"]

        except Exception as e:
            last_exception = e
            error_str = str(e)

            is_transient = any(
                keyword in error_str
                for keyword in ["429", "503", "rate_limit", "overloaded", "timeout", "UNAVAILABLE"]
            )

            if is_transient and attempt < MAX_RETRIES:
                delay = min(BASE_DELAY_SECONDS * (2 ** (attempt - 1)), MAX_DELAY_SECONDS)
                jitter = random.uniform(0, delay * 0.5)
                await asyncio.sleep(delay + jitter)
                continue

            raise

    raise last_exception  # type: ignore
