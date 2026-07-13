from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy import func
import uuid
from typing import List, Dict, Any
from datetime import datetime, timezone

from src.modules.learning_session.infrastructure.persistence.models import (
    ChallengeSession, SessionQuestion, Question, QuestionOption, SessionAnswer
)
from src.modules.learning_session.infrastructure.ai.gemini_client import generate_poo_questions
from src.modules.gamification.domain.services.xp_service import XPService
from src.shared.infrastructure.api.exceptions import APIException
from src.modules.learning_session.application.dto.challenge_dtos import AnswerRequest, AnswerResponse

XP_PER_CORRECT = 5
XP_PER_WRONG = 5

class ChallengeService:
    def __init__(self, session: AsyncSession):
        self.session = session
        self.xp_service = XPService(session)

    async def start_challenge(self, user_id: uuid.UUID) -> dict:
        try:
            questions_data = await generate_poo_questions(difficulty="intermedio", user_id=str(user_id))
        except Exception as e:
            raise APIException(code="AI_ERROR", message=f"No se pudieron generar las preguntas: {str(e)}", status_code=502)
            
        profile = await self.xp_service.get_or_create_profile(user_id)
            
        session_id = uuid.uuid4()
        challenge_session = ChallengeSession(
            id=session_id,
            user_id=user_id,
            level_id_at_start=profile.current_level_id,
            started_xp=profile.xp_total,
            status="IN_PROGRESS",
            total_questions=len(questions_data)
        )
        self.session.add(challenge_session)
        
        dto_questions = []
        option_keys = ["A", "B", "C", "D"]
        
        for idx, q_data in enumerate(questions_data):
            # 1. Create Question
            question_id = uuid.uuid4()
            question_record = Question(
                id=question_id,
                topic_id=1,
                difficulty=2,
                stem=q_data.get("stem", q_data.get("text", "")),
                explanation=q_data.get("explanation", q_data.get("feedback", "")),
                source_type="AI",
                content_hash=uuid.uuid4().hex  # simple unique hash for AI generated
            )
            self.session.add(question_record)
            
            # 2. Create Options
            options_list = q_data.get("options", [])
            formatted_options = []
            correct_option_id = q_data.get("correct_option_key", q_data.get("correct_option_id", "A"))
            
            for opt_idx, opt in enumerate(options_list):
                if isinstance(opt, dict):
                    key = opt.get("key", option_keys[opt_idx] if opt_idx < 4 else str(opt_idx))
                    text = opt.get("text", opt.get("option_text", ""))
                else:
                    key = option_keys[opt_idx] if opt_idx < 4 else str(opt_idx)
                    text = str(opt)
                
                is_correct = (key == correct_option_id)
                option_record = QuestionOption(
                    id=uuid.uuid4(),
                    question_id=question_id,
                    option_key=key,
                    option_text=text,
                    is_correct=is_correct,
                    position=opt_idx + 1
                )
                self.session.add(option_record)
                formatted_options.append({"key": key, "text": text})

            # 3. Create SessionQuestion link
            sq_id = uuid.uuid4()
            session_question = SessionQuestion(
                id=sq_id,
                session_id=session_id,
                question_id=question_id,
                order_in_session=idx + 1,
                difficulty_at_delivery=2,
                topic_id=1
            )
            self.session.add(session_question)
            
            dto_questions.append({
                "session_question_id": str(sq_id),
                "order": idx + 1,
                "difficulty": 2,
                "stem": question_record.stem,
                "options": formatted_options
            })
            
        await self.session.commit()
        return {
            "session_id": str(session_id), 
            "total_questions": len(dto_questions),
            "questions": dto_questions
        }

    async def answer_question(self, session_id: uuid.UUID, user_id: uuid.UUID, request: AnswerRequest) -> AnswerResponse:
        # Validate session question
        q_result = await self.session.execute(
            select(SessionQuestion)
            .filter(SessionQuestion.id == uuid.UUID(request.session_question_id))
            .filter(SessionQuestion.session_id == session_id)
        )
        session_question = q_result.scalars().first()
        if not session_question:
            raise APIException(code="NOT_FOUND", message="Pregunta no encontrada en este reto", status_code=404)
            
        # Check if already answered
        ans_result = await self.session.execute(
            select(SessionAnswer).filter(SessionAnswer.session_question_id == session_question.id)
        )
        existing_answer = ans_result.scalars().first()
        if existing_answer:
            raise APIException(code="ALREADY_ANSWERED", message="La pregunta ya fue respondida", status_code=400)
            
        # Find correct option
        opt_result = await self.session.execute(
            select(QuestionOption).filter(QuestionOption.question_id == session_question.question_id)
        )
        options = opt_result.scalars().all()
        correct_option = next((opt for opt in options if opt.is_correct), None)
        if not correct_option:
            raise APIException(code="INTERNAL_ERROR", message="Opciones corruptas", status_code=500)
            
        is_correct = (request.selected_option_key == correct_option.option_key)
        
        # Save Answer
        answer_record = SessionAnswer(
            id=uuid.uuid4(),
            session_question_id=session_question.id,
            session_id=session_id,
            user_id=user_id,
            selected_option_key=request.selected_option_key,
            is_correct=is_correct,
            response_time_ms=request.response_time_ms if hasattr(request, 'response_time_ms') and request.response_time_ms else 0
        )
        self.session.add(answer_record)
        
        xp_awarded = XP_PER_CORRECT if is_correct else -XP_PER_WRONG
        
        # Get explanation
        question_result = await self.session.execute(
            select(Question).filter(Question.id == session_question.question_id)
        )
        question = question_result.scalars().first()
        
        await self.session.commit()
        
        # Calculate lives remaining (Max 3 lives, minus wrong answers)
        wrong_ans_result = await self.session.execute(
            select(func.count(SessionAnswer.id))
            .filter(SessionAnswer.session_id == session_id)
            .filter(SessionAnswer.is_correct == False)
        )
        wrong_count = wrong_ans_result.scalar() or 0
        lives_remaining = max(0, 3 - wrong_count)
        
        return AnswerResponse(
            is_correct=is_correct,
            correct_option_key=correct_option.option_key,
            xp_awarded=xp_awarded,
            feedback=question.explanation if question else "",
            lives_remaining=lives_remaining
        )

    async def finish_challenge(self, session_id: uuid.UUID, user_id: uuid.UUID) -> dict:
        sess_result = await self.session.execute(
            select(ChallengeSession).filter(ChallengeSession.id == session_id, ChallengeSession.user_id == user_id)
        )
        challenge_session = sess_result.scalars().first()
        if not challenge_session or challenge_session.status != "IN_PROGRESS":
            raise APIException(code="INVALID_SESSION", message="Sesión inválida o ya finalizada", status_code=400)
            
        # Get all answers for this session
        ans_result = await self.session.execute(
            select(SessionAnswer).filter(SessionAnswer.session_id == session_id)
        )
        answers = ans_result.scalars().all()
        
        correct_answers = sum(1 for a in answers if a.is_correct)
        wrong_answers = len(answers) - correct_answers
        total_questions = challenge_session.total_questions
        
        challenge_session.status = "FINISHED"
        # Since finished_at is not in ChallengeSession, maybe it wasn't there? I will not set it to avoid errors.
        
        # Apply XP
        xp_gained = correct_answers * XP_PER_CORRECT
        xp_lost = wrong_answers * XP_PER_WRONG
        
        xp_result = await self.xp_service.apply_session_xp(
            user_id=user_id,
            xp_gained=xp_gained,
            xp_lost=xp_lost,
            correct_answers=correct_answers,
            total_questions=total_questions,
            challenge_session_id=session_id
        )
        
        await self.session.commit()
        
        return {
            "session_id": str(session_id),
            "correct_answers": correct_answers,
            "wrong_answers": wrong_answers,
            "xp_gained": xp_gained,
            "xp_lost": xp_lost,
            "xp_delta": xp_result["xp_delta"],
            "level_up": xp_result["level_up"],
            "floor_applied": xp_result["floor_applied"],
            "new_xp_total": xp_result["xp_after_final"],
            "new_level_id": xp_result["level_after"],
        }
