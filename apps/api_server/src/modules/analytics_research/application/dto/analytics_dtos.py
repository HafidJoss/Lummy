from pydantic import BaseModel
from typing import Optional, Dict, Any

class TestAttemptRequest(BaseModel):
    test_type: str       # "PRE_TEST" o "POST_TEST"
    score: int
    total_questions: int
    duration_seconds: int
    metadata: Optional[Dict[str, Any]] = None

class TestAttemptResponse(BaseModel):
    id: str
    message: str = "Evaluación registrada correctamente."
