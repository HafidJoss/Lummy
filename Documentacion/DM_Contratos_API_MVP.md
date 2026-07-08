# DM de Contratos API (MVP) — Sistema Gamificado IA para POO

## 1. Visión General
Este documento define los endpoints RESTful para la comunicación entre la aplicación móvil (Flutter) y el backend (FastAPI) del sistema gamificado. 

Se basa en los principios de diseño de un **Modulito** y utiliza nombres de recursos claros. Todas las peticiones al backend (salvo los procesos de autenticación iniciales) requieren el encabezado de autorización estándar:
`Authorization: Bearer <access_token>`

---

## 2. Módulo Identity & Access

### 2.1 Registro de Usuario
**Endpoint:** `POST /api/v1/auth/register`  
**Descripción:** Crea una nueva cuenta de estudiante en el sistema.  
**Request Body:**
```json
{
  "email": "estudiante@unsch.edu.pe",
  "password": "Password123!",
  "full_name": "Juan Pérez"
}
```
**Response (201 Created):**
```json
{
  "id": "uuid-123456",
  "email": "estudiante@unsch.edu.pe",
  "full_name": "Juan Pérez"
}
```

### 2.2 Iniciar Sesión (Login)
**Endpoint:** `POST /api/v1/auth/login`  
**Descripción:** Valida credenciales e inicia sesión devolviendo tokens JWT.  
**Request Body:**
```json
{
  "email": "estudiante@unsch.edu.pe",
  "password": "Password123!"
}
```
**Response (200 OK):**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIs...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIs...",
  "token_type": "bearer",
  "expires_in": 3600
}
```

### 2.3 Refrescar Sesión (Refresh Token)
**Endpoint:** `POST /api/v1/auth/refresh`  
**Descripción:** Renueva el `access_token` cuando expira, utilizando un `refresh_token` válido. (Cumple con seguridad JWT).  
**Request Body:**
```json
{
  "refresh_token": "eyJhbGciOiJIUzI1NiIs..."
}
```
**Response (200 OK):**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIs...",
  "token_type": "bearer",
  "expires_in": 3600
}
```

### 2.4 Cerrar Sesión (Logout)
**Endpoint:** `POST /api/v1/auth/logout`  
**Descripción:** Revoca el `refresh_token` asociado al dispositivo actual para cerrar la sesión (Cumple RF-003).  
**Response (200 OK):**
```json
{
  "message": "Sesión cerrada correctamente"
}
```

### 2.5 Obtener Perfil Actual
**Endpoint:** `GET /api/v1/users/me`  
**Descripción:** Obtiene los datos básicos y el progreso actual (gamificación) del usuario autenticado.  
**Response (200 OK):**
```json
{
  "id": "uuid-123456",
  "email": "estudiante@unsch.edu.pe",
  "full_name": "Juan Pérez",
  "display_name": "juan_perez",
  "xp_total": 125,
  "current_level_id": 2,
  "accuracy_global": 75.5
}
```

---

## 3. Módulo Learning Session & Gamification

### 3.1 Iniciar Sesión de Reto
**Endpoint:** `POST /api/v1/challenge/start`  
**Descripción:** Inicializa un nuevo reto generando 5 preguntas de POO utilizando IA (Gemini).  
**Response (201 Created):**
```json
{
  "session_id": "uuid-session-123",
  "total_questions": 5,
  "questions": [
    {
      "session_question_id": "uuid-sq-1",
      "order": 1,
      "difficulty": 2,
      "stem": "¿Qué es el encapsulamiento en la Programación Orientada a Objetos?",
      "options": [
        {"key": "A", "text": "Ocultar los detalles de implementación y estado interno."},
        {"key": "B", "text": "Heredar el comportamiento de una clase padre."},
        {"key": "C", "text": "Instanciar múltiples objetos de una clase."},
        {"key": "D", "text": "Reescribir el comportamiento de un método existente."}
      ]
    }
    // ... se omiten las 4 preguntas restantes
  ]
}
```

### 3.2 Enviar Respuesta a Pregunta
**Endpoint:** `POST /api/v1/challenge/{session_id}/answer`  
**Descripción:** Envía la respuesta seleccionada por el usuario para una pregunta particular. Otorga +5 o -5 de XP temporalmente.  
**Request Body:**
```json
{
  "session_question_id": "uuid-sq-1",
  "selected_option_key": "A",
  "response_time_ms": 4500
}
```
**Response (200 OK):**
```json
{
  "is_correct": true,
  "correct_option_key": "A",
  "xp_awarded": 5,
  "feedback": "¡Correcto! El encapsulamiento protege el estado interno de un objeto, limitando el acceso directo a sus atributos."
}
```

### 3.3 Finalizar Sesión de Reto
**Endpoint:** `POST /api/v1/challenge/{session_id}/finish`  
**Descripción:** Concluye la sesión. Dispara transaccionalmente la consolidación de XP, revisión de subida de nivel y emite eventos de dominio (Outbox).  
**Response (200 OK):**
```json
{
  "session_id": "uuid-session-123",
  "correct_answers": 4,
  "wrong_answers": 1,
  "xp_gained": 20,
  "xp_lost": 5,
  "xp_delta": 15,
  "level_up": false,
  "floor_applied": false,
  "new_xp_total": 140,
  "new_level_id": 2
}
```

---

## 4. Módulo Leaderboard

### 4.1 Obtener Ranking Global (Paginado)
**Endpoint:** `GET /api/v1/leaderboard`  
**Descripción:** Obtiene la tabla de clasificación global ordenada por XP. Es un Read Model que lee desde Redis o PostgreSQL.  
**Query Params:** `?page=1&limit=20`  
**Response (200 OK):**
```json
{
  "page": 1,
  "total_pages": 5,
  "items": [
    {
      "rank_position": 1,
      "user_id": "uuid-8888",
      "display_name": "maria_dev",
      "xp_total": 540,
      "level_id": 4,
      "accuracy_global": 92.0
    },
    {
      "rank_position": 2,
      "user_id": "uuid-9999",
      "display_name": "carlos_poo",
      "xp_total": 490,
      "level_id": 4,
      "accuracy_global": 85.5
    }
  ]
}
```

### 4.2 Obtener Mi Posición en el Ranking
**Endpoint:** `GET /api/v1/leaderboard/me`  
**Descripción:** Devuelve en qué posición exacta se encuentra el usuario autenticado actualmente en la tabla global.  
**Response (200 OK):**
```json
{
  "rank_position": 42,
  "xp_total": 140,
  "level_id": 2
}
```

---

## 5. Módulo Analytics & Research (Investigación Académica)

Para cumplir con los fines del proyecto (determinar el impacto en los estudiantes).

### 5.1 Enviar Evaluación (Pre-test / Post-test)
**Endpoint:** `POST /api/v1/analytics/test-attempt`  
**Descripción:** Permite a la app enviar el resultado de las pruebas de entrada o salida de conocimientos de POO (Cumple RF-022).  
**Request Body:**
```json
{
  "test_type": "PRE_TEST",
  "score": 14,
  "total_questions": 20,
  "duration_seconds": 950,
  "metadata": {
    "cohorte": "2026-I"
  }
}
```
**Response (201 Created):**
```json
{
  "id": "uuid-test-999",
  "message": "Evaluación registrada correctamente."
}
```

### 5.2 Exportar Dataset (Solo Investigadores / Admins)
**Endpoint:** `GET /api/v1/analytics/export`  
**Descripción:** Genera un archivo CSV/JSON anonimizado con el historial de estudiantes, niveles y métricas para uso en SPSS, R o Python (Cumple RF-023).  
**Response (200 OK):** `application/csv` o `application/json`

---

## 6. Códigos de Error Comunes (Manejo de Excepciones)

Las respuestas fallidas seguirán este esquema base estándar:
```json
{
  "detail": "Mensaje legible del error",
  "code": "ERROR_CODE"
}
```

*   `400 Bad Request`: Formato de request inválido (ej. Pydantic validation error, o intentar responder dos veces la misma pregunta).
*   `401 Unauthorized`: Token faltante, expirado o inválido.
*   `403 Forbidden`: Acción no permitida para el usuario.
*   `404 Not Found`: Recurso no encontrado (ej. sesión de reto inexistente `session_id`).
*   `503 Service Unavailable`: Falla temporal externa (ej. error en la API de Gemini 1.5 sin fallback de preguntas locales disponible).
