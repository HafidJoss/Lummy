import os
import json
import google.genai as genai
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

def get_gemini_client():
    api_key = os.getenv("GEMINI_API_KEY", "dummy_key_for_tests")
    return genai.Client(api_key=api_key)

async def generate_poo_questions(difficulty: str, user_id: str) -> list[dict]:
    """Genera 5 preguntas dinámicas sobre Programación Orientada a Objetos."""
    client = get_gemini_client()
    prompt = f"Genera 5 preguntas de opción múltiple sobre Programación Orientada a Objetos en Python. La dificultad debe ser {difficulty}. Para cada pregunta, provee 4 opciones (A, B, C, D) y la justificación de la respuesta correcta. Asegúrate de devolver el resultado siguiendo estrictamente el esquema JSON solicitado."
    
    response = client.models.generate_content(
        model='gemini-flash-latest',
        contents=prompt,
        config=genai.types.GenerateContentConfig(
            response_mime_type="application/json",
            response_schema=ChallengeQuestions,
        ),
    )
    
    data = json.loads(response.text)
    return data["questions"]
