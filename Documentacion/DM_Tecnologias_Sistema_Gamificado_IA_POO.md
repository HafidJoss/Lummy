# DM de Tecnologías — Sistema Gamificado Basado en IA para Aprendizaje de POO

## 1) Propósito del documento

Definir de manera formal y detallada el stack tecnológico del sistema gamificado basado en IA para aprendizaje de Programación Orientada a Objetos (POO), justificando cada tecnología según:

- Requerimientos funcionales del MVP.
- Escalabilidad y mantenibilidad.
- Rendimiento en móviles.
- Robustez de backend y datos.
- Soporte al enfoque de investigación (métricas pre/post-test, retención, participación, motivación).

---

## 2) Principios de selección tecnológica

1. **Productividad para MVP** sin sacrificar calidad arquitectónica.
2. **Ecosistema maduro** y comunidad activa.
3. **Compatibilidad con Clean/Hexagonal + DDD ligero**.
4. **Baja latencia percibida** para experiencia gamificada.
5. **Capacidad de evolución** (modulith → servicios separados cuando sea necesario).
6. **Trazabilidad y observabilidad** para validación académica.

---

## 3) Stack tecnológico oficial

## 3.1 Frontend móvil

### Tecnología principal
- **Flutter (Dart, última versión estable)**

### Rol en el sistema
- Desarrollo de app móvil nativa multiplataforma (Android/iOS).
- Construcción de UI gamificada (dashboard, sesión de preguntas, feedback inmediato, leaderboard).
- Gestión de estado por features.
- Integración segura con APIs REST del backend.

### Justificación técnica
- Alto rendimiento de renderizado (cercano a 60fps si se diseña correctamente).
- Código único para Android/iOS reduce tiempo y costo.
- Excelente para interfaces reactivas y animaciones.
- Ecosistema sólido de librerías para red, almacenamiento seguro y enrutamiento.

### Librerías recomendadas (base MVP)
- **HTTP Client:** `dio`
- **State Management:** `flutter_bloc` o `riverpod` (elegir uno, no mezclar)
- **Routing:** `go_router`
- **Secure Storage:** `flutter_secure_storage`
- **Serialización JSON:** `json_serializable` + `build_runner`
- **Equidad y comparaciones:** `equatable`

### Animaciones e interactividad
- **Rive**
  - State Machines para estados de juego: `Idle`, `Loading`, `Success`, `Fail`.
  - Feedback visual instantáneo por respuesta correcta/incorrecta.
  - Mejora de percepción de fluidez durante latencia de red.

---

## 3.2 Backend API

### Tecnología principal
- **Python 3.12+**
- **FastAPI**

### Rol en el sistema
- Exponer API RESTful segura para autenticación, sesiones, gamificación, leaderboard y analíticas.
- Orquestar generación de preguntas con IA.
- Validar y sanear respuestas de IA.
- Ejecutar reglas de negocio (XP, niveles, piso antifrustración).

### Justificación técnica
- FastAPI ofrece alto rendimiento y asincronía nativa.
- Tipado con Pydantic mejora confiabilidad de contratos API.
- Excelente compatibilidad con Clean Architecture y testing.
- Curva de desarrollo rápida para iteraciones del MVP.

### Componentes backend recomendados
- **Servidor ASGI:** `uvicorn` (prod: `gunicorn` + workers Uvicorn)
- **Validación:** `pydantic v2`
- **ORM:** `SQLAlchemy 2.x`
- **Migraciones:** `Alembic`
- **Autenticación JWT:** `python-jose` o `PyJWT`
- **Hash de contraseñas:** `passlib` (bcrypt/argon2)
- **Cliente HTTP async:** `httpx`
- **Tests:** `pytest`, `pytest-asyncio`

---

## 3.3 Base de datos transaccional

### Tecnología principal
- **PostgreSQL (v16 o estable compatible)**

### Rol en el sistema
- Fuente de verdad para usuarios, progreso, sesiones, respuestas, reglas de nivel y eventos de negocio.
- Persistencia transaccional confiable para lógica crítica de gamificación.

### Justificación técnica
- ACID robusto.
- Excelente rendimiento en consultas relacionales.
- Soporte JSONB útil para logs de IA y eventos enriquecidos.
- Gran madurez para producción y analítica.

### Uso recomendado
- Índices clave:
  - `(user_id, created_at)`
  - `(xp_total DESC)`
  - índices por `session_id` y `occurred_at` en tablas de eventos.
- Separar write model y read model (CQRS selectivo).

---

## 3.4 Caché y rendimiento de lectura

### Tecnología principal
- **Redis**

### Rol en el sistema
- Caché de leaderboard (top N y páginas frecuentes).
- Almacenamiento temporal de datos de sesión de baja criticidad.
- (Opcional) broker inicial para eventos ligeros.

### Justificación técnica
- Latencia muy baja para consultas frecuentes.
- Reduce carga del PostgreSQL en escenarios de alto tráfico de lectura.
- Fácil integración con Python y arquitectura modulith.

---

## 3.5 Mensajería y procesamiento asíncrono

### Estrategia
- Iniciar con **Outbox Pattern + workers**.
- Elegir broker según escala:

#### Opción MVP
- **Redis (Pub/Sub o Streams)** para eventos simples.

#### Opción crecimiento
- **RabbitMQ** para colas de trabajo confiables (ack, retries, DLQ).

#### Opción alta escala analítica
- **Kafka** para alto throughput y consumo por múltiples proyectores/servicios.

### Rol en el sistema
- Desacoplar procesamiento no bloqueante:
  - actualización de leaderboard,
  - generación de read models,
  - analíticas e instrumentación.

---

## 3.6 Motor de Inteligencia Artificial

### Tecnología principal
- **Gemini 1.5 Flash API** (según diseño planteado)

### Rol en el sistema
- Generación dinámica de preguntas de opción múltiple sobre POO.
- Ajuste de dificultad por nivel del estudiante.
- Retroalimentación teórica por pregunta.

### Justificación técnica
- Baja latencia relativa para interacción casi en tiempo real.
- Buen desempeño en generación estructurada con instrucciones estrictas.
- Útil para rotación temática y adaptatividad.

### Controles obligatorios de calidad IA
1. **Prompt estructurado y versionado.**
2. **Respuesta en JSON estricto.**
3. **Validación de esquema con Pydantic.**
4. **Verificaciones de consistencia:**
   - respuesta correcta ∈ opciones,
   - no repetición de temas recientes,
   - no duplicados semánticos inmediatos.
5. **Fallback local**: banco de preguntas predefinidas si IA falla/retrasa.

---

## 3.7 Seguridad y autenticación

### Tecnologías
- JWT access token + refresh token.
- Hash de contraseñas con Argon2 o BCrypt.
- Almacenamiento seguro de tokens en Flutter (`flutter_secure_storage`).

### Controles recomendados
- Rotación de refresh tokens.
- Revocación por lista/bloqueo de sesión.
- Rate limiting en endpoints sensibles (`/auth/login`, `/challenge/start`).
- Validación estricta de entrada (Pydantic + reglas de dominio).
- CORS restringido y manejo seguro de secretos por entorno.

---

## 3.8 Observabilidad y monitoreo

### Tecnologías recomendadas
- **Logging estructurado:** `structlog` o logging JSON estándar.
- **Métricas:** Prometheus + Grafana (o alternativa cloud equivalente).
- **Trazas:** OpenTelemetry (opcional en MVP, recomendado al escalar).
- **Errores:** Sentry (frontend + backend).

### KPIs técnicos mínimos
- Latencia p50/p95/p99 por endpoint.
- Tasa de error HTTP 4xx/5xx.
- Tiempo de respuesta de proveedor IA.
- Ratio de reintentos/fallback IA.
- Tiempo de actualización de leaderboard.
- Tasa de abandono de sesión de juego.

---

## 3.9 DevOps, despliegue y entornos

### Contenerización
- **Docker** para backend, workers, PostgreSQL y Redis en entorno dev/staging.

### Orquestación
- MVP: `docker-compose`.
- Escala futura: Kubernetes (si hay múltiples servicios y alta concurrencia).

### CI/CD
- **GitHub Actions**
  - lint + tests + seguridad básica + build.
  - despliegue por ambiente (dev/staging/prod).

### Gestión de configuración
- Variables de entorno por ambiente.
- Secretos gestionados por vault/secret manager (no en repositorio).

---

## 3.10 Testing y calidad

### Backend
- Unit tests: dominio y casos de uso.
- Integration tests: repositorios, API, DB.
- Contract tests: esquemas request/response.
- Pruebas de resiliencia IA: respuestas inválidas, timeout, fallback.

### Frontend
- Widget tests para UI crítica.
- Tests de estado por feature (BLoC/Riverpod).
- Integration tests de flujos principales:
  - login,
  - iniciar reto,
  - responder preguntas,
  - ver leaderboard actualizado.

### Calidad estática
- Python: `ruff`, `black`, `mypy` (si aplicable).
- Dart: `flutter analyze`, `dart format`.

---

## 4) Matriz resumida de tecnologías

| Capa | Tecnología | Propósito |
|---|---|---|
| App móvil | Flutter + Dart | UI nativa Android/iOS |
| Animación | Rive | Feedback visual interactivo |
| API | FastAPI (Python) | Lógica de negocio y orquestación |
| Validación | Pydantic | Contratos y esquemas robustos |
| Persistencia | PostgreSQL | Datos transaccionales y consistencia |
| Caché | Redis | Acelerar lecturas y leaderboard |
| IA | Gemini 1.5 Flash | Generación adaptativa de preguntas |
| Mensajería | Redis/Rabbit/Kafka | Eventos y procesamiento async |
| Auth | JWT + Refresh | Seguridad de sesiones |
| Observabilidad | Prometheus/Grafana/Sentry | Monitoreo y diagnóstico |
| DevOps | Docker + GitHub Actions | Entornos reproducibles y CI/CD |

---

## 5) Versiones objetivo sugeridas (baseline)

> Nota: fijar versiones exactas al crear el repositorio para garantizar reproducibilidad.

- Python: 3.12.x
- FastAPI: estable actual compatible
- Pydantic: v2.x
- SQLAlchemy: 2.x
- PostgreSQL: 16.x
- Redis: 7.x
- Flutter: canal stable actual
- Dart: versión incluida por Flutter stable
- Docker Engine: versión estable actual

---

## 6) Riesgos tecnológicos y mitigaciones

1. **Salida inválida de IA**
   - Mitigación: validación fuerte + retries + fallback local.

2. **Cuello de botella en leaderboard**
   - Mitigación: CQRS de lectura + Redis + proyecciones por evento.

3. **Acoplamiento temprano a proveedor IA**
   - Mitigación: puerto `QuestionGeneratorPort` + adapter intercambiable.

4. **Crecimiento de complejidad operativa**
   - Mitigación: modulith disciplinado antes de microservicios.

5. **Pérdida de eventos en fallos parciales**
   - Mitigación: Outbox + idempotencia + DLQ.

---

## 7) Decisiones tecnológicas obligatorias (para alinear al equipo)

1. Usar **una sola estrategia de estado** en Flutter (BLoC o Riverpod).
2. Implementar backend por módulos con límites claros (no “shared” excesivo).
3. Aplicar CQRS solo en leaderboard/reportes, no en todo el sistema.
4. Toda integración IA debe pasar por validación de esquema.
5. Implementar outbox antes de pasar a producción piloto.
6. Definir desde inicio eventos y métricas para investigación.

---

## 8) Roadmap tecnológico por fases

### Fase 1 — MVP funcional
- Flutter + FastAPI + PostgreSQL.
- Auth JWT, sesión de retos, cálculo XP, nivel.
- Integración IA con validación.
- Leaderboard básico paginado.

### Fase 2 — Endurecimiento
- Redis caché leaderboard.
- Outbox + worker para proyecciones.
- Observabilidad (logs/métricas/errores).
- Mejoras de seguridad y rate limits.

### Fase 3 — Escalado
- Broker dedicado (Rabbit/Kafka según carga).
- Separación de componentes calientes (leaderboard/analytics/IA).
- Trazas distribuidas y SLOs formales.

---

## 9) Conclusión

El stack seleccionado es adecuado para construir un sistema:

- **rápido de desarrollar** (ideal para MVP académico),
- **robusto en producción** (validación, seguridad, observabilidad),
- **escalable de forma incremental** (sin sobrearquitectura temprana),
- y **alineado a objetivos de investigación**, gracias a su capacidad de instrumentación y análisis.