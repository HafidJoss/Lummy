from pydantic import BaseModel
from typing import List, Optional

class OptionDTO(BaseModel):
    key: str          # "A", "B", "C", "D"
    text: str

class QuestionDTO(BaseModel):
    session_question_id: str
    order: int
    difficulty: int
    stem: str
    options: List[OptionDTO]

class StartChallengeResponse(BaseModel):
    session_id: str
    total_questions: int = 5
    questions: List[QuestionDTO]

class AnswerRequest(BaseModel):
    session_question_id: str
    selected_option_key: str    # "A", "B", "C", "D"
    response_time_ms: int = 0

class AnswerResponse(BaseModel):
    is_correct: bool
    correct_option_key: str
    xp_awarded: int
    feedback: str
    lives_remaining: int = 3

class FinishChallengeResponse(BaseModel):
    session_id: str
    correct_answers: int
    wrong_answers: int
    xp_gained: int
    xp_lost: int
    xp_delta: int
    level_up: bool
    floor_applied: bool
    new_xp_total: int
    new_level_id: int
