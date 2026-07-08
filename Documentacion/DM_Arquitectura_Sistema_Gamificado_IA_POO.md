# DM de Arquitectura — Sistema Gamificado IA para POO

## 1) Visión de arquitectura (resumen)

Este documento define la arquitectura objetivo para el sistema gamificado de aprendizaje de POO, usando la combinación acordada:

- Flutter (feature-first) en frontend.
- FastAPI Modulith en backend.
- Clean/Hexagonal en backend.
- DDD ligero en dominio.
- Eventos de dominio + cola (Redis/Rabbit/Kafka según escala).
- CQRS solo para leaderboard y reportes.
- PostgreSQL como fuente de verdad + Redis caché.

### Principios rectores

1. **Separación fuerte de responsabilidades** (dominio, aplicación, infraestructura, presentación).
2. **Escalado progresivo** (modulith primero, microservicios después).
3. **Resiliencia operacional** (outbox, idempotencia, reintentos controlados).
4. **Observabilidad desde el diseño** (logs, métricas, trazas).
5. **Compatibilidad con investigación académica** (telemetría y analíticas reproducibles).

---

## 2) Estructura global del repositorio (monorepo recomendado)

```txt
gamified-poo-system/
├─ apps/
│  ├─ mobile_app/                      # Flutter app
│  └─ api_server/                      # FastAPI modulith
├─ packages/                           # Librerías compartidas (opcional)
│  ├─ contracts/                       # Schemas OpenAPI/JSON/shared DTOs
│  └─ design_tokens/                   # Tema UI compartido (si aplica)
├─ infra/
│  ├─ docker/
│  │  ├─ docker-compose.dev.yml
│  │  ├─ docker-compose.prod.yml
│  │  └─ images/
│  ├─ k8s/                             # Manifiestos (cuando escale)
│  ├─ terraform/                       # IaC opcional
│  └─ scripts/
├─ docs/
│  ├─ architecture/
│  │  ├─ 01-context.md
│  │  ├─ 02-container.md
│  │  ├─ 03-components.md
│  │  ├─ 04-domain-model.md
│  │  ├─ 05-event-catalog.md
│  │  ├─ 06-cqrs.md
│  │  └─ 07-security-observability.md
│  ├─ api/
│  └─ adr/                             # Architecture Decision Records
├─ .github/
│  └─ workflows/
├─ Makefile
├─ README.md
└─ .env.example
```

---

## 3) Backend FastAPI Modulith — estructura completa

```txt
apps/api_server/
├─ src/
│  ├─ main.py                          # Entry point FastAPI
│  ├─ bootstrap.py                     # Wiring de dependencias
│  ├─ config/
│  │  ├─ settings.py                   # Pydantic settings
│  │  ├─ logging.py
│  │  └─ feature_flags.py
│  ├─ shared/                          # Kernel compartido (no negocio específico)
│  │  ├─ domain/
│  │  │  ├─ entity.py                  # BaseEntity
│  │  │  ├─ value_object.py
│  │  │  ├─ domain_event.py
│  │  │  └─ errors.py
│  │  ├─ application/
│  │  │  ├─ command.py
│  │  │  ├─ query.py
│  │  │  ├─ handlers.py
│  │  │  └─ bus_interfaces.py
│  │  ├─ infrastructure/
│  │  │  ├─ db/
│  │  │  │  ├─ base.py                 # SQLAlchemy base/session
│  │  │  │  ├─ uow.py                  # Unit of Work
│  │  │  │  └─ migrations/             # Alembic
│  │  │  ├─ cache/
│  │  │  │  └─ redis_client.py
│  │  │  ├─ messaging/
│  │  │  │  ├─ event_bus.py            # Publisher/subscriber
│  │  │  │  ├─ outbox_publisher.py
│  │  │  │  └─ broker_clients/         # redis/rabbit/kafka adapters
│  │  │  ├─ observability/
│  │  │  │  ├─ metrics.py
│  │  │  │  ├─ tracing.py
│  │  │  │  └─ logging.py
│  │  │  └─ security/
│  │  │     ├─ jwt_service.py
│  │  │     ├─ password_hasher.py
│  │  │     └─ rbac.py
│  │  └─ presentation/
│  │     ├─ api_response.py
│  │     ├─ exception_handlers.py
│  │     └─ dependencies.py
│  │
│  ├─ modules/
│  │  ├─ identity_access/
│  │  │  ├─ domain/
│  │  │  │  ├─ entities/
│  │  │  │  │  ├─ user.py
│  │  │  │  │  └─ refresh_token.py
│  │  │  │  ├─ value_objects/
│  │  │  │  │  ├─ email.py
│  │  │  │  │  └─ hashed_password.py
│  │  │  │  ├─ repositories/
│  │  │  │  │  └─ user_repository.py
│  │  │  │  ├─ services/
│  │  │  │  │  └─ auth_domain_service.py
│  │  │  │  └─ events/
│  │  │  │     └─ user_registered.py
│  │  │  ├─ application/
│  │  │  │  ├─ commands/
│  │  │  │  │  ├─ register_user.py
│  │  │  │  │  ├─ login_user.py
│  │  │  │  │  └─ refresh_session.py
│  │  │  │  ├─ queries/
│  │  │  │  │  └─ get_my_profile.py
│  │  │  │  ├─ dto/
│  │  │  │  └─ ports/
│  │  │  │     ├─ token_provider_port.py
│  │  │  │     └─ password_hasher_port.py
│  │  │  ├─ infrastructure/
│  │  │  │  ├─ persistence/
│  │  │  │  │  ├─ models.py
│  │  │  │  │  ├─ repositories_sqlalchemy.py
│  │  │  │  │  └─ mappers.py
│  │  │  │  ├─ security/
│  │  │  │  │  └─ jwt_adapter.py
│  │  │  │  └─ api/
│  │  │  │     ├─ schemas.py
│  │  │  │     └─ router.py
│  │  │  └─ tests/
│  │  │
│  │  ├─ learning_session/
│  │  │  ├─ domain/
│  │  │  │  ├─ entities/
│  │  │  │  │  ├─ challenge_session.py
│  │  │  │  │  ├─ question.py
│  │  │  │  │  └─ answer_record.py
│  │  │  │  ├─ value_objects/
│  │  │  │  │  ├─ difficulty.py
│  │  │  │  │  └─ topic_id.py
│  │  │  │  ├─ repositories/
│  │  │  │  │  ├─ session_repository.py
│  │  │  │  │  └─ question_repository.py
│  │  │  │  ├─ services/
│  │  │  │  │  └─ session_scoring_service.py
│  │  │  │  └─ events/
│  │  │  │     ├─ session_started.py
│  │  │  │     ├─ question_answered.py
│  │  │  │     └─ session_finished.py
│  │  │  ├─ application/
│  │  │  │  ├─ commands/
│  │  │  │  │  ├─ start_challenge.py
│  │  │  │  │  ├─ submit_answer.py
│  │  │  │  │  └─ finish_session.py
│  │  │  │  ├─ queries/
│  │  │  │  │  └─ get_active_session.py
│  │  │  │  ├─ dto/
│  │  │  │  └─ ports/
│  │  │  │     └─ question_generator_port.py
│  │  │  ├─ infrastructure/
│  │  │  │  ├─ ai/
│  │  │  │  │  ├─ gemini_client.py
│  │  │  │  │  ├─ prompt_builder.py
│  │  │  │  │  ├─ response_validator.py
│  │  │  │  │  └─ fallback_question_bank.py
│  │  │  │  ├─ persistence/
│  │  │  │  │  ├─ models.py
│  │  │  │  │  ├─ repositories_sqlalchemy.py
│  │  │  │  │  └─ mappers.py
│  │  │  │  └─ api/
│  │  │  │     ├─ schemas.py
│  │  │  │     └─ router.py
│  │  │  └─ tests/
│  │  │
│  │  ├─ gamification/
│  │  │  ├─ domain/
│  │  │  │  ├─ entities/
│  │  │  │  │  ├─ student_progress.py
│  │  │  │  │  └─ level_rule.py
│  │  │  │  ├─ value_objects/
│  │  │  │  │  ├─ xp.py
│  │  │  │  │  └─ level.py
│  │  │  │  ├─ repositories/
│  │  │  │  │  ├─ progress_repository.py
│  │  │  │  │  └─ level_rule_repository.py
│  │  │  │  ├─ services/
│  │  │  │  │  └─ xp_policy_service.py
│  │  │  │  └─ events/
│  │  │  │     ├─ xp_changed.py
│  │  │  │     └─ level_up.py
│  │  │  ├─ application/
│  │  │  │  ├─ commands/
│  │  │  │  │  └─ apply_session_result.py
│  │  │  │  ├─ queries/
│  │  │  │  │  └─ get_progress.py
│  │  │  │  ├─ dto/
│  │  │  │  └─ policies/
│  │  │  ├─ infrastructure/
│  │  │  │  ├─ persistence/
│  │  │  │  └─ api/
│  │  │  └─ tests/
│  │  │
│  │  ├─ leaderboard/
│  │  │  ├─ domain/
│  │  │  │  ├─ entities/
│  │  │  │  │  └─ leaderboard_entry.py
│  │  │  │  ├─ repositories/
│  │  │  │  │  ├─ leaderboard_read_repository.py
│  │  │  │  │  └─ leaderboard_cache_repository.py
│  │  │  │  └─ events/
│  │  │  │     └─ leaderboard_rebuilt.py
│  │  │  ├─ application/
│  │  │  │  ├─ queries/
│  │  │  │  │  ├─ get_leaderboard_page.py
│  │  │  │  │  └─ get_my_rank.py
│  │  │  │  └─ projectors/
│  │  │  │     └─ leaderboard_projector.py
│  │  │  ├─ infrastructure/
│  │  │  │  ├─ readmodel/
│  │  │  │  │  ├─ models.py
│  │  │  │  │  └─ repositories_sql.py
│  │  │  │  ├─ cache/
│  │  │  │  │  └─ redis_leaderboard_repo.py
│  │  │  │  └─ api/
│  │  │  │     ├─ schemas.py
│  │  │  │     └─ router.py
│  │  │  └─ tests/
│  │  │
│  │  └─ analytics_research/
│  │     ├─ domain/
│  │     │  ├─ entities/
│  │     │  │  ├─ learning_metric.py
│  │     │  │  └─ experiment_cohort.py
│  │     │  ├─ repositories/
│  │     │  │  ├─ metrics_write_repository.py
│  │     │  │  └─ metrics_read_repository.py
│  │     │  └─ events/
│  │     │     └─ metric_registered.py
│  │     ├─ application/
│  │     │  ├─ commands/
│  │     │  │  └─ register_learning_event.py
│  │     │  ├─ queries/
│  │     │  │  ├─ get_pre_post_results.py
│  │     │  │  ├─ get_retention_kpis.py
│  │     │  │  └─ export_dataset.py
│  │     │  └─ projectors/
│  │     │     └─ analytics_projector.py
│  │     ├─ infrastructure/
│  │     │  ├─ persistence/
│  │     │  ├─ readmodel/
│  │     │  └─ api/
│  │     └─ tests/
│  │
│  ├─ workers/
│  │  ├─ leaderboard_worker.py
│  │  ├─ analytics_worker.py
│  │  └─ dead_letter_handler.py
│  └─ tests/
│     ├─ unit/
│     ├─ integration/
│     └─ e2e/
├─ pyproject.toml
├─ alembic.ini
└─ README.md
```

---

## 4) Explicación de cada capa (backend)

### `domain/`
- Entidades, value objects, eventos y reglas de negocio puras.
- No conoce FastAPI, SQLAlchemy ni SDK de IA.
- Aquí vive la lógica crítica: XP, nivel, piso antifrustración, validaciones de invariantes.

### `application/`
- Casos de uso (commands/queries).
- Orquesta el dominio y define puertos (`ports`) para infraestructura.
- Punto ideal para transacciones y coordinación de repositorios.

### `infrastructure/`
- Implementaciones concretas: PostgreSQL, Redis, broker, cliente Gemini, JWT.
- Mappers ORM, repositorios SQLAlchemy y adaptadores externos.

### `presentation/api/`
- Routers FastAPI, schemas HTTP y dependencias de autenticación.
- Traduce HTTP <-> DTO de aplicación.

### `workers/`
- Consumidores asíncronos de eventos.
- Actualizan read models, caché y reportes sin bloquear requests de usuario.

---

## 5) DDD ligero aplicado a módulos

### Bounded Contexts

1. **Identity & Access**
   - Registro/login/refresh.
   - Control de sesión y seguridad JWT.

2. **Learning Session**
   - Inicio y ejecución de retos de 5 preguntas.
   - Registro de respuestas y cierre de sesión.

3. **Gamification**
   - Cálculo XP +5/-5.
   - Reglas de nivel y piso antifrustración.

4. **Leaderboard**
   - Ranking global paginado.
   - Consultas optimizadas de posición.

5. **Analytics/Research**
   - Métricas de aprendizaje, retención y resultados pre/post-test.
   - Exportación para análisis estadístico.

---

## 6) CQRS (uso selectivo)

Se aplica solo en módulos de alta lectura analítica:

- **Write model (transaccional)**: `learning_session`, `gamification`.
- **Read model (consulta rápida)**: `leaderboard`, `analytics_research`.

### Flujo resumido
1. Se escribe verdad de negocio en PostgreSQL transaccional.
2. Se emite evento de dominio (vía outbox).
3. Worker/proyector consume evento.
4. Actualiza tabla de lectura y/o Redis.
5. API de consultas lee del read model/caché.

---

## 7) Eventos de dominio y mensajería

### Catálogo base de eventos
- `SessionStarted`
- `QuestionAnswered`
- `SessionFinished`
- `XPChanged`
- `LevelUp`
- `LeaderboardRebuilt`
- `MetricRegistered`

### Metadata obligatoria
- `event_id` (UUID)
- `event_type`
- `occurred_at`
- `aggregate_id`
- `user_id`
- `version`
- `idempotency_key`

---

## 8) Outbox pattern (consistencia)

Para evitar pérdida de eventos:

1. Dentro de la misma transacción:
   - Guardar cambio de negocio.
   - Guardar evento en `outbox_events`.
2. Publisher worker:
   - Lee outbox pendiente.
   - Publica al broker.
   - Marca como publicado.
3. Consumidores:
   - Verifican `processed_events` (idempotencia).
   - Si ya procesado, ignoran duplicado.

---

## 9) Frontend Flutter feature-first — estructura completa

```txt
apps/mobile_app/
├─ lib/
│  ├─ app/
│  │  ├─ app.dart
│  │  ├─ router/
│  │  │  ├─ app_router.dart
│  │  │  └─ guards.dart
│  │  ├─ theme/
│  │  └─ di/
│  ├─ core/
│  │  ├─ network/
│  │  │  ├─ dio_client.dart
│  │  │  ├─ interceptors/
│  │  │  │  ├─ auth_interceptor.dart
│  │  │  │  └─ retry_interceptor.dart
│  │  ├─ storage/
│  │  │  ├─ secure_storage.dart
│  │  │  └─ local_cache.dart
│  │  ├─ error/
│  │  ├─ utils/
│  │  └─ widgets/
│  ├─ features/
│  │  ├─ auth/
│  │  │  ├─ data/
│  │  │  ├─ domain/
│  │  │  └─ presentation/
│  │  ├─ dashboard/
│  │  ├─ challenge_session/
│  │  │  ├─ data/
│  │  │  ├─ domain/
│  │  │  └─ presentation/
│  │  │     ├─ pages/
│  │  │     ├─ widgets/
│  │  │     └─ rive/
│  │  │        ├─ challenge_state_machine.riv
│  │  │        └─ rive_controller.dart
│  │  ├─ gamification_progress/
│  │  ├─ leaderboard/
│  │  └─ analytics_view/
│  ├─ l10n/
│  └─ main.dart
├─ test/
├─ pubspec.yaml
└─ README.md
```

### Regla de oro en Flutter
Cada feature encapsula:
- `data` (models, datasource, repository impl)
- `domain` (entities, usecases, repository contracts)
- `presentation` (state management + UI)

---

## 10) Esquema mínimo de base de datos (MVP sólido)

Tablas sugeridas:

- `users`
- `user_profiles` (xp_total, level, accuracy_global)
- `challenge_sessions`
- `questions`
- `session_answers`
- `level_rules`
- `leaderboard_read_model`
- `learning_metrics_read_model`
- `outbox_events`
- `processed_events`

---

## 11) Reglas de modularidad obligatorias

1. Un módulo no accede directo a repositorios internos de otro módulo.
2. Comunicación inter-módulo por:
   - casos de uso públicos, o
   - eventos de dominio/integración.
3. `shared/` solo para utilidades transversales (no lógica de negocio específica).
4. Todo cambio de regla de negocio debe vivir en `domain/`.
5. Toda integración externa debe entrar por `ports/adapters`.

---

## 12) Seguridad, rendimiento y observabilidad

### Seguridad
- JWT access + refresh token.
- Hash robusto de contraseñas (Argon2/Bcrypt).
- Rotación/revocación de refresh tokens.
- Rate limiting por endpoint sensible (`login`, `start_challenge`).

### Rendimiento
- Índices: `(user_id, created_at)`, `(xp_total DESC)`.
- Paginación obligatoria en leaderboard.
- Redis para top N + rank lookup.
- Timeouts y retry con backoff en llamadas a Gemini.

### Observabilidad
- Logging estructurado con correlation-id.
- Métricas: latencia p95/p99, errores IA, ratio de reintentos, abandono de sesión.
- Trazas distribuidas (OpenTelemetry opcional).

---

## 13) Estrategia de escalado por etapas

### Etapa 1 (MVP)
- Modulith único.
- PostgreSQL + Redis.
- Worker simple para outbox/projectores.

### Etapa 2 (crecimiento moderado)
- Separar lectura de leaderboard (servicio read-only opcional).
- Endurecer colas y DLQ.

### Etapa 3 (alta escala)
- Extraer `ai-question-generator`.
- Extraer `analytics`.
- Broker robusto (Rabbit/Kafka según volumen/eventos).

---

## 14) ADRs recomendados (crear en `/docs/adr`)

1. ADR-001: Elección de Modulith vs Microservicios iniciales.
2. ADR-002: Adopción de Clean/Hexagonal.
3. ADR-003: DDD ligero y bounded contexts.
4. ADR-004: CQRS selectivo (leaderboard/analytics).
5. ADR-005: Outbox pattern e idempotencia.
6. ADR-006: PostgreSQL + Redis como estrategia de datos.
7. ADR-007: Política de integración con IA (validación/fallback).

---

## 15) Checklist de cumplimiento arquitectónico

- [ ] Dominio sin dependencias de framework.
- [ ] Casos de uso por comando/query separados.
- [ ] Eventos críticos definidos y versionados.
- [ ] Outbox + consumers idempotentes implementados.
- [ ] Read models para leaderboard y analytics.
- [ ] Telemetría de investigación activa (pre/post, retención, precisión).
- [ ] Índices DB y caché validados con pruebas de carga.
- [ ] Documentación C4 + ADRs actualizada.

---

## 16) Conclusión

La arquitectura propuesta equilibra **mantenibilidad, escalabilidad y velocidad de entrega**.  
Permite arrancar rápido con un MVP robusto (modulith), sin bloquear el crecimiento futuro hacia servicios independientes.  
Además, preserva la calidad metodológica necesaria para medir el impacto académico del sistema gamificado basado en IA.