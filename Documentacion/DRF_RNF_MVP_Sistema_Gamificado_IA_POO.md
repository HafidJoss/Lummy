# Documento de Requisitos Funcionales y No Funcionales (MVP)
## Sistema Gamificado Basado en IA para Aprendizaje de POO

## 1. Propósito del documento

Definir de forma clara, verificable y trazable los **requisitos funcionales (RF)** y **no funcionales (RNF)** del Producto Mínimo Viable (MVP) del sistema gamificado basado en IA para estudiantes de Ingeniería de Sistemas de la UNSCH.

Este documento servirá como base para:
- planificación de desarrollo,
- validación de alcance MVP,
- pruebas de aceptación,
- y evaluación académica del impacto del sistema.

---

## 2. Alcance del MVP

El MVP incluye:

- App móvil (Android/iOS) para estudiantes.
- Backend API RESTful.
- Autenticación segura con JWT.
- Generación de preguntas de POO mediante IA (JSON estructurado).
- Sesiones de reto de 5 preguntas.
- Sistema de XP, niveles y piso antifrustración.
- Leaderboard competitivo con paginación.
- Registro de métricas de aprendizaje y uso.
- Soporte para análisis pre-test/post-test.

No incluye en MVP:
- sistema docente completo,
- chat en tiempo real,
- evaluación de código compilable,
- modo offline completo.

---

## 3. Actores del sistema

1. **Estudiante (usuario principal)**
   - Se autentica, resuelve retos, visualiza progreso y ranking.

2. **Investigador/Administrador académico**
   - Consulta datos agregados para evaluación del impacto (métricas, reportes).

3. **Sistema IA (Gemini API)**
   - Genera preguntas estructuradas de acuerdo al contexto del usuario.

4. **Servicios internos del sistema**
   - Motor de gamificación, motor de leaderboard, módulo de analíticas.

---

## 4. Supuestos y dependencias

- El estudiante cuenta con conexión a internet.
- El proveedor IA está disponible con latencia aceptable.
- El sistema utiliza PostgreSQL como fuente de verdad y Redis como caché.
- El aplicativo móvil usa autenticación basada en JWT con refresh token.
- El catálogo de temas de POO está predefinido y activo.

---

## 5. Requisitos funcionales (RF)

## 5.1 Gestión de usuarios y autenticación

### RF-001 Registro de usuario
**Descripción:** El sistema debe permitir que un estudiante cree una cuenta con email y contraseña.  
**Prioridad:** Alta  
**Criterio de aceptación:**
- Dado email válido no registrado, cuando envía formulario, entonces se crea cuenta.
- Si email ya existe, se rechaza con mensaje claro.

### RF-002 Inicio de sesión
**Descripción:** El sistema debe autenticar usuario y entregar access token + refresh token.  
**Prioridad:** Alta  
**Criterio de aceptación:**
- Credenciales válidas generan tokens.
- Credenciales inválidas retornan error 401.

### RF-003 Cierre de sesión
**Descripción:** El sistema debe invalidar la sesión del dispositivo (revocar refresh token).  
**Prioridad:** Media

### RF-004 Perfil de usuario
**Descripción:** El sistema debe mostrar perfil con nombre, XP total, nivel, precisión global y posición en ranking (si disponible).  
**Prioridad:** Alta

---

## 5.2 Flujo de reto gamificado

### RF-005 Inicio de reto
**Descripción:** El usuario puede iniciar una sesión de reto desde el dashboard.  
**Prioridad:** Alta  
**Regla:** Cada sesión tiene exactamente 5 preguntas.

### RF-006 Orquestación de contexto para IA
**Descripción:** Al iniciar reto, el backend debe construir contexto con nivel, rendimiento e historial reciente para solicitar preguntas a IA.  
**Prioridad:** Alta

### RF-007 Generación de preguntas por IA
**Descripción:** El backend debe solicitar 5 preguntas de opción múltiple en JSON estructurado.  
**Prioridad:** Alta  
**Criterio de aceptación:**
- El JSON cumple esquema requerido.
- Si falla validación, se reintenta y/o usa fallback local.

### RF-008 Rotación temática anti-repetición
**Descripción:** El sistema debe excluir temas de las últimas N preguntas recientes (N=15 en diseño actual) para reducir repetición.  
**Prioridad:** Alta

### RF-009 Presentación y respuesta de preguntas
**Descripción:** El usuario debe responder cada pregunta seleccionando una opción.  
**Prioridad:** Alta

### RF-010 Retroalimentación inmediata
**Descripción:** Tras cada respuesta, el sistema debe mostrar si fue correcta/incorrecta junto con explicación conceptual.  
**Prioridad:** Alta

### RF-011 Cierre de sesión y cálculo final
**Descripción:** Al terminar las 5 preguntas, el sistema debe calcular resultados de sesión y actualizar progreso del usuario.  
**Prioridad:** Alta

---

## 5.3 Gamificación (XP, nivel, reglas)

### RF-012 Puntuación por respuesta
**Descripción:** El sistema asigna +5 XP por respuesta correcta y -5 XP por incorrecta.  
**Prioridad:** Alta

### RF-013 Cálculo de XP de sesión
**Descripción:** El sistema debe acumular XP neto por sesión y persistirlo en ledger.  
**Prioridad:** Alta

### RF-014 Sistema de niveles
**Descripción:** El sistema debe determinar nivel del usuario según rangos de XP configurados en `level_rules`.  
**Prioridad:** Alta

### RF-015 Piso antifrustración
**Descripción:** El sistema no debe permitir que el XP final de un usuario baje del mínimo de su nivel consolidado actual.  
**Prioridad:** Alta  
**Ejemplo:** si está en Nivel 2, no baja de 100 XP.

### RF-016 Visualización de progreso
**Descripción:** Mostrar nivel actual, barra de progreso XP y precisión global actualizada.  
**Prioridad:** Alta

---

## 5.4 Leaderboard

### RF-017 Ranking global
**Descripción:** El sistema debe mostrar tabla de clasificación global por XP total descendente.  
**Prioridad:** Alta

### RF-018 Paginación de leaderboard
**Descripción:** El ranking debe estar paginado para eficiencia de lectura.  
**Prioridad:** Alta

### RF-019 Posición del usuario autenticado
**Descripción:** El sistema debe mostrar la posición actual del usuario en el ranking.  
**Prioridad:** Media

---

## 5.5 Analíticas y evaluación académica

### RF-020 Registro de eventos de aprendizaje
**Descripción:** El sistema debe registrar eventos clave: inicio/fin de sesión, respuesta por pregunta, tiempo de respuesta, aciertos/errores.  
**Prioridad:** Alta

### RF-021 Cálculo de métricas de rendimiento
**Descripción:** El sistema debe calcular y almacenar métricas de precisión por sesión y global.  
**Prioridad:** Alta

### RF-022 Registro pre-test y post-test
**Descripción:** El sistema debe almacenar resultados de instrumentos pre-test y post-test por estudiante.  
**Prioridad:** Alta

### RF-023 Exportación de datos para investigación
**Descripción:** El sistema debe permitir exportar dataset anonimizable para análisis académico.  
**Prioridad:** Media

---

## 5.6 Resiliencia funcional IA

### RF-024 Validación estructural de respuesta IA
**Descripción:** Toda salida IA debe validarse contra esquema definido antes de usarse.  
**Prioridad:** Alta

### RF-025 Fallback por falla IA
**Descripción:** Si IA no responde correctamente tras reintentos configurados, el sistema debe usar preguntas de banco fallback.  
**Prioridad:** Alta

### RF-026 No interrupción del flujo del usuario
**Descripción:** Una falla de IA no debe bloquear completamente la sesión del estudiante.  
**Prioridad:** Alta

---

## 6. Requisitos no funcionales (RNF)

## 6.1 Rendimiento y escalabilidad

### RNF-001 Tiempo de respuesta API
- Endpoints estándar: p95 < 500 ms (sin incluir generación IA).
- Endpoints de sesión con IA: respuesta inicial percibida con loader inmediato; tiempo objetivo backend+IA < 4 s p95 en condiciones normales.

### RNF-002 Capacidad concurrente MVP
- Soportar al menos 300 usuarios concurrentes en pruebas de carga académica inicial.

### RNF-003 Leaderboard eficiente
- Consultas paginadas p95 < 250 ms con caché Redis activa.

### RNF-004 Escalado progresivo
- Arquitectura debe permitir separar módulos calientes (leaderboard, analytics, IA) sin rediseño total.

---

## 6.2 Disponibilidad y resiliencia

### RNF-005 Disponibilidad del servicio
- Disponibilidad objetivo MVP: 99.0% mensual en ventana académica.

### RNF-006 Manejo de fallos externos
- Timeouts y reintentos con backoff para proveedor IA.
- Circuit breaker o política equivalente recomendada para evitar cascadas de error.

### RNF-007 Consistencia de eventos
- Publicación de eventos mediante outbox pattern.
- Consumidores idempotentes obligatorios.

---

## 6.3 Seguridad

### RNF-008 Protección de credenciales
- Contraseñas con hash fuerte (Argon2/Bcrypt), nunca texto plano.

### RNF-009 Autenticación y autorización
- JWT access + refresh token.
- Expiración y revocación de sesiones activas.

### RNF-010 Seguridad de datos en tránsito
- Todo tráfico cliente-servidor y servidor-proveedor externo mediante HTTPS/TLS.

### RNF-011 Protección contra abuso
- Rate limiting en login, inicio de reto y endpoints sensibles.

### RNF-012 Privacidad de datos
- Minimización de datos personales en logs.
- Dataset de investigación con anonimización/pseudonimización.

---

## 6.4 Mantenibilidad y calidad

### RNF-013 Arquitectura modular
- Implementación respetando Clean/Hexagonal + DDD ligero.

### RNF-014 Cobertura de pruebas
- Cobertura mínima sugerida:
  - dominio/casos de uso: >= 80%
  - integración crítica: >= 70%

### RNF-015 Calidad estática
- Linting y formateo obligatorio en CI/CD.
- Revisión de PR obligatoria para ramas protegidas.

### RNF-016 Trazabilidad
- Cada RF/RNF debe vincularse a historias de usuario, casos de prueba y evidencias de validación.

---

## 6.5 Usabilidad y experiencia de usuario

### RNF-017 Fluidez de interfaz
- Transiciones y feedback visual sin bloqueos perceptibles.
- Uso de animaciones Rive para enmascarar latencia de red.

### RNF-018 Claridad de retroalimentación
- Mensajes de acierto/error y explicación conceptual comprensibles y breves.

### RNF-019 Accesibilidad básica
- Tamaños de fuente legibles, contraste adecuado, navegación clara en pantallas principales.

---

## 6.6 Compatibilidad y despliegue

### RNF-020 Plataformas móviles
- Android (obligatorio MVP), iOS (objetivo funcional si presupuesto/tiempo lo permite).

### RNF-021 Entornos
- Entornos separados: desarrollo, pruebas, producción.

### RNF-022 Contenerización
- Backend y servicios de soporte desplegables con Docker.

---

## 6.7 Observabilidad

### RNF-023 Logging estructurado
- Logs JSON con correlation_id por request/sesión.

### RNF-024 Métricas operativas
- Métricas mínimas: latencia, errores, throughput, tasa de fallback IA, abandono de sesiones.

### RNF-025 Monitoreo de negocio
- KPIs: precisión, sesiones/usuario, retención D1/D7, mejora pre-post, distribución de niveles.

---

## 7. Matriz de trazabilidad resumida (RF ↔ módulos)

| Requisito | Módulo principal |
|---|---|
| RF-001..RF-004 | Identity & Access |
| RF-005..RF-011 | Learning Session |
| RF-012..RF-016 | Gamification |
| RF-017..RF-019 | Leaderboard (CQRS read) |
| RF-020..RF-023 | Analytics/Research |
| RF-024..RF-026 | Integración IA + Resiliencia |

---

## 8. Criterios de aceptación del MVP (salida a piloto)

El MVP se considera listo para piloto cuando:

1. Se completa el flujo extremo a extremo:
   - login → iniciar reto → responder 5 preguntas → cierre → actualización ranking.
2. Reglas de gamificación se aplican sin inconsistencias:
   - +5/-5, niveles, piso antifrustración.
3. Leaderboard funciona con paginación y rendimiento objetivo.
4. Eventos de analítica se registran correctamente.
5. Existe evidencia de pruebas funcionales y no funcionales mínimas.
6. Se valida seguridad base (auth, hash, tokens, rate limits).
7. Existe fallback ante falla de IA.

---

## 9. Riesgos de cumplimiento de requisitos

1. **Latencia de IA** afecta RNF-001/RNF-017  
   - Mitigación: loaders, timeout, fallback.
2. **Datos incompletos para investigación** afectan RF-020..023  
   - Mitigación: contrato de eventos obligatorio desde sprint 1.
3. **Inconsistencias de XP/nivel** afectan RF-012..015  
   - Mitigación: lógica centralizada backend + pruebas unitarias de dominio.
4. **Sobrecarga del leaderboard** afecta RNF-003  
   - Mitigación: CQRS + Redis.

---

## 10. Glosario breve

- **XP:** Experience Points (puntos de experiencia).
- **Piso antifrustración:** límite inferior de XP del nivel consolidado.
- **CQRS:** separación entre modelo de escritura y lectura.
- **Outbox Pattern:** patrón para publicar eventos de forma confiable.
- **p95:** percentil 95 de latencia.

---

## 11. Control de cambios del documento

- **Versión:** 1.0
- **Estado:** Borrador listo para validación técnica
- **Fecha:** 2026-07-02
- **Autoría:** Equipo de arquitectura del proyecto MVP