from fastapi import Request
from fastapi.responses import JSONResponse
from typing import Any, Dict, Optional
import traceback

class APIException(Exception):
    def __init__(self, code: str, message: str, status_code: int = 400, details: Optional[Dict[str, Any]] = None):
        self.code = code
        self.message = message
        self.status_code = status_code
        self.details = details or {}

async def api_exception_handler(request: Request, exc: APIException):
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "error": {
                "code": exc.code,
                "message": exc.message,
                "details": exc.details
            }
        }
    )

async def global_exception_handler(request: Request, exc: Exception):
    # Log the exception stack trace to terminal
    traceback.print_exc()
    return JSONResponse(
        status_code=500,
        content={
            "error": {
                "code": "INTERNAL_SERVER_ERROR",
                "message": "Ha ocurrido un error inesperado en el servidor.",
                "details": {"type": str(type(exc).__name__)}
            }
        }
    )
